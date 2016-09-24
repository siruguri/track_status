class TwitterClientWrapper
  attr_reader :client
  class TwitterClientArgumentException < Exception
  end
  def config
    @config ||= {}
  end
  
  def initialize(opts = {})
    token_rec = opts[:token]
    
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key    = Rails.application.secrets.twitter_consumer_key
      config.consumer_secret = Rails.application.secrets.twitter_consumer_secret
      if token_rec.nil?
        config.access_token    = Rails.application.secrets.twitter_single_app_access_token
        config.access_token_secret = Rails.application.secrets.twitter_single_app_access_token_secret
      else
        config.access_token = token_rec.token
        config.access_token_secret = token_rec.secret
      end
    end

    config[:access_token] = opts[:token].present? ? opts[:token].token
                            : Rails.application.secrets.twitter_single_app_access_token
  end

  def perform_now(handle_rec, command, opts)
    response = instance_eval("#{command}(handle_rec, opts)")    
  end
    
  def rate_limited(&block)
    curr_time = Time.now
    if config[:access_token].nil?
      tok = Rails.application.secrets.twitter_single_app_access_token
    else
      tok = config[:access_token]
    end
      
    ct = TwitterRequestRecord.where('created_at > ? and request_for = ?', curr_time - 1.minute, tok).count
    
    if ct >= 12
      t = TwitterRequestRecord.last
      t.ran_limit = true
      t.save

      # Enforce max of 12 requests per minute = 180 per 15 min window
      sleep 60 unless Rails.env.test?
    end

    instance_eval(&block) if block_given?
  end

  private
  def twitter_regex
    # http://t.co/gboESznVDm
    /https?...t\.co.[^\s]+/
  end

  def save_articles!(article_list, handle)
    # Try to save a list of URLs, if they aren't in the db already
    return if article_list.empty?
    
    existing_urls = WebArticle.where(original_url: article_list).pluck :original_url
    article_list -= existing_urls

    if article_list.size > 0    
      # No callbacks
      article_list = article_list.uniq.select { |u| WebArticle.valid_uri?(u) }

      # This query really eats up a lot of disk space in development
      ActiveRecord::Base.logger.level = 1
      WebArticle.import(
        article_list.map { |new_url| WebArticle.new(original_url: new_url, source: 'twitter', twitter_profile: handle) }
      )
      ActiveRecord::Base.logger.level = 0      
      
      TwitterRedirectFetchJob.perform_later article_list
    end
  end
  
  def make_web_article_list(entity_hash)
    # Return list of URLs found in tweets as long as they don't point to twitter.com

    return [] unless entity_hash
    created_articles = []
    entity_hash[:urls].each do |s|
      unless s[:expanded_url].match '.twitter.com'
        created_articles << s[:expanded_url]
      end
    end

    created_articles
  end

  def account_settings!(user_rec)
    # Don't run this method unless we have a user authenticating to Twitter

    return unless user_rec.class == User and config[:access_token].present?

    t = TwitterProfile.new(user: user_rec)
    payload = get(t, :account_settings)
    twitter_id = payload[:data][:id]
    
    if (prev = TwitterProfile.find_by_twitter_id twitter_id).present?
      begin
        prev.user = user_rec
        prev.save!
      rescue ActiveRecord::RecordNotUnique => e
      # User can't claim a profile already claimed by someone else
        rec = TwitterRequestRecord.last
        rec.update_attributes status_message: rec.status_message + ": error: already claimed by #{user_rec.id}"
      end
    else
      t.handle = payload[:data][:screen_name]
      t.save!
    end
  end

  def retweet!(handle_rec, opts)
    payload = post(handle_rec, :retweet, opts)
  end
  
  def tweet!(handle_rec, opts)
    payload = post(handle_rec, :tweet, opts)
  end
  
  def fetch_followers!(handle_rec)
    unless (last_req = TwitterRequestRecord.where(user: handle_rec, request_type: 'follower_ids')).empty?
      cursor = last_req[0].cursor
    else
      cursor = -1
    end
    
    payload = get(handle_rec, :follower_ids, {cursor: cursor})
    if payload[:data] != ''
      existing_twitter_ids = handle_rec.followers.pluck :twitter_id
      
      ts = TwitterProfile.where(twitter_id: payload[:data][:ids]).all
      ts.each do |t|
        handle_rec.followers << t unless handle_rec.followers.include? t
      end

      stale_ids = handle_rec.followers.where('twitter_id not in (?)', payload[:data][:ids]).pluck :id
      new_ids = payload[:data][:ids] - existing_twitter_ids

      # Remove stale graph connections
      GraphConnection.where('leader_id = ? and follower_id in (?)', handle_rec.id, stale_ids).map &:delete
      new_ids.each do |id|
        t = TwitterProfile.new(twitter_id: id, protected: false)
        handle_rec.followers << t
      end
    end
  end

  def fetch_my_friends!(handle_rec)
    unless (last_req = TwitterRequestRecord.where(user: handle_rec, request_type: 'following_ids')).empty?
      cursor = last_req[0].cursor
    else
      cursor = -1
    end
    
    payload = get(handle_rec, :following_ids, {cursor: cursor})
    if payload[:data] != ''
      ts = TwitterProfile.where(twitter_id: payload[:data][:ids]).all
      ts.each do |t|
        t.followers << handle_rec unless t.followers.include? handle_rec
      end

      new_ids = payload[:data][:ids] - ts.map { |t| t.twitter_id }
      new_ids.each do |id|
        new_friend = TwitterProfile.create(twitter_id: id, protected: false)
        new_friend.followers << handle_rec
      end
    end
  end
  
  def fetch_profile!(handle_rec)
    # Don't fetch if the data is relatively fresh
    if handle_rec.bio.present? and handle_rec.updated_at > Time.now - 5.minutes
      return
    end
    
    payload = get(handle_rec, :profile, {count: 100})

    if payload[:data] != ''
      handle_rec.handle ||= payload[:data][:screen_name]
      handle_rec.twitter_id ||= payload[:data][:id]
      
      handle_rec.bio = payload[:data][:description]
      handle_rec.location = payload[:data][:location]
      handle_rec.last_tweet = payload[:data][:status]
      unless payload[:data][:status].nil?
        handle_rec.last_tweet_time = DateTime.strptime(payload[:data][:status][:created_at],
                                                       '%a %b %d %H:%M:%S %z %Y')
      end
      handle_rec.member_since = payload[:data][:created_at]
      handle_rec.tweets_count = payload[:data][:statuses_count]
      handle_rec.num_following = payload[:data][:friends_count]
      handle_rec.num_followers = payload[:data][:followers_count]

      handle_rec.save
    end

    payload
  end

  def fetch_tweets!(handle_rec, opts = {})
    # opts[:relative_id] == -1 if there are no existing tweets to key to
    limiter = nil
    direction = opts[:direction].try(:to_sym) || :newer
    relative_id = opts[:relative_id]
    
    case direction
    when :newer
      limiter = :since_id
    when :older
      limiter = :max_id
    else
      raise TwitterClientArgumentException.new("#{direction} is not a valid direction (either :newer or :older)")
    end

    # This might be a fetch for a brand new profile (relative_id is -1 for dummy tweet)
    get_hash = (relative_id == -1 || limiter.nil?) ? {} : {limiter: limiter, limit_id: relative_id}

    # Pagination
    if opts[:since_id].present? and direction == :older
      get_hash.merge! ({since_id: opts[:since_id]})
    end
    
    payload = get(handle_rec, :tweets, get_hash)

    # Sometimes, there are no new tweets, or nothing older than what's the newest one provided (which returns 1 obj)
    unless (data = payload[:data]).blank? or (data.size == 1 && direction == :older)
      # This app is designed to create profiles even if only handles are avlbl, but requires Twitter IDs to match
      # tweets to users. So we have to grab the twitter id from the Twitter API response sometimes.

      if handle_rec.twitter_id.present?
        fk = handle_rec.twitter_id
      else
        fk = data.first[:user][:id]
        handle_rec.twitter_id = fk
        handle_rec.save
      end

      new_tweets = []
      all_web_articles = []      
      data.each do |tweet|
        # Scan and store all the URLs into web article models; remove them from the tweets
        is_retweeted = false
        unless tweet[:retweeted_status].nil?
          tweet[:retweeted_status][:text].gsub! twitter_regex, ''
          is_retweeted = true
        end

        new_tweets << Tweet.new(tweet_details: tweet, tweet_id: tweet[:id], mesg: tweet[:text],
                                tweeted_at: tweet[:created_at], user: handle_rec, is_retweeted: is_retweeted)
        new_tweets.last.mesg.gsub! twitter_regex, ''
        all_web_articles += make_web_article_list tweet[:entities]
      end

      Tweet.import new_tweets, on_duplicate_key_ignore: true
      save_articles! all_web_articles, handle_rec

      # Paginate tweets but don't go crazy trying to fetch tweets for new profiles the first time
      if relative_id != -1 && opts[:pagination] != false
        pass_since = 
          if opts[:since_id].present? && direction == :older
            {since_id: opts[:since_id]}
          elsif direction == :newer && relative_id != -1
            {since_id: relative_id}
          else
            {}
          end
        next_opts = ({direction: 'older', relative_id: new_tweets.last.tweet_id}).merge pass_since
        TwitterFetcherJob.perform_later(handle_rec, 'tweets', next_opts)
      end
    end

    payload
  end

  def get(handle_rec, command = :profile, opts = {})
    base_request(:get, handle_rec, command, opts)
  end
  def post(handle_rec, command = :profile, opts = {})
    base_request(:post, handle_rec, command, opts)
  end
  
  def base_request(method, handle_rec, command = :profile, opts = {})
    return nil if (handle_rec.user.nil? and command == :account_settings) or
      (handle_rec.handle.nil? and handle_rec.twitter_id.nil? and
       [:follower_ids, :profile, :tweets, :following_ids].include? command)

    if handle_rec.handle.present?
      twitter_pk_hash = {screen_name: handle_rec.handle}
    elsif handle_rec.twitter_id.present?
      twitter_pk_hash = {user_id: handle_rec.twitter_id}
    end

    case command
    when :retweet
      return nil unless opts[:tweet_id]
      req = Twitter::REST::Request.new(@client, method, "/1.1/statuses/retweet/#{opts[:tweet_id]}.json")
    when :tweet
      # Allows me to say text instead of status in my code if I want to
      real_opts = opts.clone
      real_opts[:status] = real_opts[:text] unless real_opts[:status]
      
      req = Twitter::REST::Request.new(@client, method, "/1.1/statuses/update.json",
                                       twitter_pk_hash.merge(real_opts.select{ |k, v| k == :status}))
    when :account_settings
      req = Twitter::REST::Request.new(@client, method, "/1.1/account/settings.json")
    when :follower_ids
      req = Twitter::REST::Request.new(@client, method, "/1.1/followers/ids.json",
                                       twitter_pk_hash.merge(opts.select { |k, v| k == :cursor }))
    when :following_ids
      req = Twitter::REST::Request.new(@client, method, "/1.1/friends/ids.json",
                                       twitter_pk_hash.merge(opts.select { |k, v| k == :cursor }))
    when :profile
      req = Twitter::REST::Request.new(@client, method, "/1.1/users/show.json", twitter_pk_hash)
    when :tweets
      addl_opts = {}
      unless opts.empty?
        addl_opts = {opts[:limiter] => opts[:limit_id]}
        # Tweet pagination
        if opts[:since_id]
          addl_opts.merge! ({since_id: opts[:since_id]})
        end
      end

      tweets_hash = {
        include_rts: true, trim_user: 1,  exclude_replies: true, count: 200
      }.merge(twitter_pk_hash).merge(addl_opts)
      
      req = Twitter::REST::Request.new(@client, method, "/1.1/statuses/user_timeline.json",
                                       tweets_hash)
    end

    status = true
    cursor = -1
    errors = {}
    body = ''
    
    begin
      response = req.perform
    rescue Twitter::Error, Twitter::Error::NotFound => e
      errors = {errors: "handle db id: #{handle_rec.id}, error: #{e.message}"}
    else
      body =
        if response.is_a? Hash and response.keys.size == 2 and response.keys.include?(:headers)
          # At one point I was mucking with the Twitter gem to force it to return the actual HTTP
          # response, so I could look at its headers
          response[:body]
        else
          response
        end
      
      case command
      when :tweets
        cursor = body.blank? ? opts[:limit_id] : body.last[:id]
      when :follower_ids
        cursor = body[:next_cursor]
      end
    end

    c = TwitterRequestRecord.create request_type: command, cursor: cursor, status: errors.empty?,
                                status_message: errors.empty? ? '' : errors[:errors],
                                request_for: config[:access_token],
                                handle: (command == :account_settings ? body[:screen_name] : handle_rec.handle)

    if /not authorized/i.match c.status_message
      handle_rec.update_attributes protected: true
    end
    
    {data: body}.merge errors
  end
end

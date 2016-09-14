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
    return if article_list.empty?
    
    existing_urls = WebArticle.where(original_url: article_list).pluck :original_url
    article_list -= existing_urls

    # No callbacks
    article_list = article_list.uniq
    WebArticle.import(
      article_list.map { |new_url| WebArticle.new(original_url: new_url, source: 'twitter', twitter_profile: handle) }
    )
    
    TwitterRedirectFetchJob.perform_later article_list
  end
  
  def make_web_article_list(entity_hash)
    # Return list of URLs found in tweets

    return [] unless entity_hash
    created_articles = []
    entity_hash[:urls].each do |s|
      unless s[:expanded_url].match '.twitter.com'
        w = WebArticle.new(original_url: s[:expanded_url])
        if w.valid?
          created_articles << s[:expanded_url]
        end
      end
    end

    created_articles
  end

  def account_settings!(user_rec)
    # Don't run this method unless we have a user authenticating to Twitter

    return unless user_rec.class == User and config[:access_token].present?

    t = TwitterProfile.new(user: user_rec)
    payload = get(t, :account_settings)
    handle = payload[:data][:screen_name]

    if (prev = TwitterProfile.find_by_handle handle).present?
      prev.user = user_rec
      prev.save!
    else
      t.handle = handle
      t.save!
    end
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
      ts = TwitterProfile.where(twitter_id: payload[:data][:ids]).all
      ts.each do |t|
        handle_rec.followers << t unless handle_rec.followers.include? t
      end

      new_ids = payload[:data][:ids] - ts.map { |t| t.twitter_id }
      new_ids.each do |id|
        handle_rec.followers <<  TwitterProfile.new(twitter_id: id)
      end
    end
  end
  
  def fetch_my_feed!(handle_rec)
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
        new_friend = TwitterProfile.create(twitter_id: id)
        new_friend.followers << handle_rec
      end
    end
  end
  
  def fetch_profile!(handle_rec)
    # Don't fetch if the data is relatively fresh
    Rails.logger.debug ">>> trying #{handle_rec.twitter_id}"    
    if handle_rec.bio.present? and handle_rec.updated_at > Time.now - 2.days
      Rails.logger.debug ">>> Ignoring #{handle_rec.twitter_id}"
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
      handle_rec.tweets_count = payload[:data][:statuses_count]
      handle_rec.num_following = payload[:data][:friends_count]
      handle_rec.num_followers = payload[:data][:followers_count]
      handle_rec.save
    end

    payload
  end

  def fetch_tweets!(handle_rec, relative_to_tweet = nil, opts = {})
    limiter = nil
    direction = opts[:direction].try(:to_sym) || :older
    
    unless relative_to_tweet.blank?
      case direction
      when :newer
        limiter = :since_id
        limit_id = relative_to_tweet.tweet_id
      when :older
        limiter = :max_id
        limit_id = relative_to_tweet.tweet_id
      else
        raise TwitterClientArgumentException.new("#{direction} is not a valid direction (either :newer or :older)")
      end
    end

    payload = get(handle_rec, :tweets, limiter.nil? ? {} : {limiter: limiter, limit_id: limit_id})

    # Sometimes, there are no new tweets
    if payload[:data] != '' and ((data = payload[:data]).size > 0)
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

      Tweet.import new_tweets
      save_articles! all_web_articles, handle_rec
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
      end
      
      req = Twitter::REST::Request.new(@client, method, "/1.1/statuses/user_timeline.json", {
                                         count: 200, include_rts: true, trim_user: 1,
                                         mexclude_replies: true
                                       }.merge(twitter_pk_hash).merge(addl_opts))
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
      if response.is_a? Hash and response.keys.size == 2 and response.keys.include?(:headers)
        # At one point I was mucking with the Twitter gem to force it to return the actual HTTP
        # response, so I could look at its headers
        body = response[:body]
        Rails.logger.debug "Headers are: #{response[:headers].inspect}"
      else
        body = response
      end
      
      case command
      when :tweets
        cursor = body.blank? ? opts[:limit_id] : (opts[:limiter] == :since_id ? body.first[:id] : body.last[:id])
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

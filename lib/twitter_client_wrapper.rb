class TwitterClientWrapper
  attr_reader :client
  class TwitterClientArgumentException < Exception
  end
  
  def initialize(opts = {})
    token_hash = opts[:token]
    
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key    = Rails.application.secrets.twitter_consumer_key
      config.consumer_secret = Rails.application.secrets.twitter_consumer_secret
      if token_hash.nil?
        config.access_token    = Rails.application.secrets.twitter_single_app_access_token
        config.access_token_secret = Rails.application.secrets.twitter_single_app_access_token_secret
      else
        config.access_token = token_hash[:token]
        config.access_token_secret = token_hash[:secret]
      end
    end
  end

  def rate_limited(&block)
    limited = true
    if limited
      curr_time = Time.now
      ct = TwitterRequestRecord.where('created_at > ?', curr_time - 1.minute).count
      if ct < 12
        limited = false
      else
        t = TwitterRequestRecord.last
        t.ran_limit = true
        t.save
        sleep 60 unless Rails.env.test?
      end
    end
    
    instance_eval(&block) if block_given?
  end

  private
  def twitter_regex
    # http://t.co/gboESznVDm
    /https?...t\.co.[^\s]+/
  end

  def make_web_article(entity_hash, tp)
    entity_hash[:urls].each do |s|
      unless s[:expanded_url].match '.twitter.com'
        w = WebArticle.find_or_create_by(original_url: s[:expanded_url])
        # Ignore this article if someone already tweeted about it.
        unless w.source == 'twitter'
          w.source = 'twitter'
          w.tweet_packet = tp
          w.save
          TwitterRedirectFetchJob.perform_later w
        end
      end
    end
  end

  def fetch_followers!(handle_rec)
    payload = get(handle_rec, :follower_ids)
    if payload[:data] != ''
      payload[:data][:ids].each do |id|
        t = TwitterProfile.find_or_create_by(twitter_id: id)
        handle_rec.followers << t
      end
    end
  end
  
  def fetch_profile!(handle_rec)
    payload = get(handle_rec, :profile, {count: 100})

    if payload[:data] != ''
      handle_rec.handle ||= payload[:data][:screen_name]
      handle_rec.twitter_id ||= payload[:data][:id]
      
      handle_rec.bio = payload[:data][:description]
      handle_rec.location = payload[:data][:location]
      handle_rec.last_tweet = payload[:data][:status]
      handle_rec.tweets_count = payload[:data][:statuses_count]
      handle_rec.num_following = payload[:data][:friends_count]
      handle_rec.num_followers = payload[:data][:followers_count]
      handle_rec.save
    end

    payload
  end

  def fetch_tweets!(handle_rec, relative_to_packet = nil, opts = {})
    limiter = nil
    direction = opts[:direction] ? opts[:direction].to_sym : :older
    unless relative_to_packet.blank?
      case direction
      when :newer
        limiter = :since_id
        limit_id = relative_to_packet.first[:id]
      when :older
        limiter = :max_id
        limit_id = relative_to_packet.last[:id]
      else
        raise TwitterClientArgumentException.new("#{direction} is not a valid direction from :newer and :older")
      end
    end

    payload = get(handle_rec, :tweets, limiter.nil? ? {} : {limiter: limiter, limit_id: limit_id})

    # Sometimes, there are no new tweets
    if payload[:data] != '' and ((data = payload[:data]).size > 0)
      tweets_list = data.collect do |tweet|
        {mesg: tweet[:text], id: tweet[:id], entities: tweet[:entities],
         retweeted_status: tweet[:retweeted_status], retweet_count: tweet[:retweet_count]
        }
      end

      # This app is designed to create profiles using handles, but requires Twitter IDs to match
      # tweets to users. So we have to grab the twitter id from the Twitter API response sometimes.
      if handle_rec.twitter_id
        fk = handle_rec.twitter_id
      else
        fk = data.first[:user][:id]
      end
      
      tp = TweetPacket.new(twitter_id: fk, max_id: data.last[:id],
                           since_id: data.first[:id],
                           newest_tweet_at: data.first[:created_at], oldest_tweet_at: data.last[:created_at])
      # Scan and store all the URLs into web article models; remove them from the tweets
      tweets_list.each do |t|
        t[:mesg].gsub! twitter_regex, ''
        make_web_article t[:entities], tp
        unless t[:retweeted_status].nil?
          t[:retweeted_status][:text].gsub! twitter_regex, ''
        end
      end

      tp.tweets_list = tweets_list; tp.save

      saved = false
      while !saved
        begin
          tp.save!
        rescue SQLite3::BusyException => e
          sleep 5
        else
          saved = true
        end
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
    return nil if handle_rec.handle.nil? and handle_rec.twitter_id.nil? or
      !([:follower_ids, :profile, :tweets].include? command)
    
    if handle_rec.handle
      twitter_pk_hash = {screen_name: handle_rec.handle}
    else
      twitter_pk_hash = {user_id: handle_rec.twitter_id}
    end
    
    case command
    when :follower_ids
      req = Twitter::REST::Request.new(@client, method, "/1.1/followers/ids.json", twitter_pk_hash)
    when :profile
      req = Twitter::REST::Request.new(@client, method, "/1.1/users/show.json", twitter_pk_hash)
    when :tweets
      addl_opts = {}
      unless opts.empty?
        addl_opts = {opts[:limiter] => opts[:limit_id]}        
      end
      
      req = Twitter::REST::Request.new(@client, method, "/1.1/statuses/user_timeline.json", {
                                         count: 200, include_rts: true, trim_user: 1,
                                         exclude_replies: true}.merge(twitter_pk_hash).merge(addl_opts))
    end

    status = true
    cursor = -1
    errors = {}
    body = ''
    
    begin
      Rails.logger.debug("Performing query to twitter: #{req.path} with option #{req.options}")
      response = req.perform
    rescue Twitter::Error::NotFound => e
      errors = {errors: 'Handle not found'}
    else
      if response.is_a? Hash and response.keys.size == 2 and response.keys.include?(:headers)
        body = response[:body]
        Rails.logger.debug "Headers are: #{response[:headers].inspect}"
      else
        body = response
        Rails.logger.debug "Body is: #{body}"
      end
      case command
      when :tweets
        cursor = body.blank? ? opts[:limit_id] : (opts[:limiter] == :since_id ? body.first[:id] : body.last[:id])
      end
    end

    TwitterRequestRecord.create request_type: command, cursor: cursor, status: errors.empty?, handle: handle_rec.handle

    {data: body}.merge errors
  end
end

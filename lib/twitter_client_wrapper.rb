class TwitterClientWrapper
  attr_reader :client
  class TwitterClientArgumentException < Exception
  end
  
  def initialize(opts = {})
    token_hash = opts[:token]
    
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      if token_hash.nil?
        config.access_token    = ENV['TWITTER_SINGLE_APP_ACCESS_TOKEN']
        config.access_token_secret = ENV['TWITTER_SINGLE_APP_ACCESS_TOKEN_SECRET']
      else
        config.access_token = token_hash[:token]
        config.access_token_secret = token_hash[:secret]
        Rails.logger.debug("Using token #{token_hash[:token]}")
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
        sleep 60
      end
    end
    
    instance_eval(&block) if block_given?
  end

  private

  def fetch_profile!(handle_rec)
    payload = get(handle_rec, :profile, {count: 100})

    if payload[:data] != ''
      handle_rec.bio = payload[:data][:description]
      handle_rec.location = payload[:data][:location]

      handle_rec.save
    end

    payload
  end

  def fetch_tweets!(handle_rec, relative_to_packet = nil, direction = :older)
    limiter = nil
    unless relative_to_packet.nil?
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

    if payload[:data] != ''
      data = payload[:data]
      tweets_list = data.collect { |tweet| {mesg: tweet[:text], id: tweet[:id],
                                            retweeted_status: tweet[:retweeted_status]} }

      TweetPacket.create(handle: handle_rec.handle, tweets_list: tweets_list, max_id: data.last[:id],
                         since_id: data.first[:id],
                         newest_tweet_at: data.first[:created_at], oldest_tweet_at: data.last[:created_at])
    end

    payload
  end

  def get(handle_rec, command = :profile, opts = {})
    return nil unless [:profile, :tweets].include? command

    case command
    when :profile
      req = Twitter::REST::Request.new(@client, :get, "/1.1/users/show.json", {screen_name: handle_rec.handle})
    when :tweets
      addl_opts = {}
      unless opts.empty?
        addl_opts = {opts[:limiter] => opts[:limit_id]}        
      end
      
      req = Twitter::REST::Request.new(@client, :get, "/1.1/statuses/user_timeline.json", {
                                         count: 200, include_rts: true, screen_name: handle_rec.handle, trim_user: 1,
                                         exclude_replies: true}.merge(addl_opts))
    end

    status = true
    cursor = -1
    errors = {}
    body = ''
    
    Rails.logger.debug("Performing query to twitter: #{req.path} with option #{req.options}")
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
      end
      case command
      when :tweets
        cursor = body.last[:max_id]
      end
    end

    TwitterRequestRecord.create request_type: command, cursor: cursor, status: errors.empty?, handle: handle_rec.handle

    {data: body}.merge errors
  end
end

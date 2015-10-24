class TwitterClientWrapper
  attr_reader :client
  
  def initialize
    @client = Twitter::REST::Client.new do |config|
      if Object.const_defined?("Rails")
        config.consumer_key    = Rails.application.secrets.twitter_consumer_key
        config.consumer_secret = Rails.application.secrets.twitter_consumer_secret
        config.access_token    = Rails.application.secrets.twitter_single_app_access_token
        config.access_token_secret = Rails.application.secrets.twitter_single_app_access_token_secret
      else
        config.consumer_key    = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token    = ENV['TWITTER_SINGLE_APP_ACCESS_TOKEN']
        config.access_token_secret = ENV['TWITTER_SINGLE_APP_ACCESS_TOKEN_SECRET']
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
        sleep 1
      end
    end
    
    instance_eval(&block) if block_given?
  end

  private

  def fetch_profile!(handle_rec)
    payload = get(handle_rec, :profile, {count: 100})

    unless payload.keys.include? :errors
      status = true
      handle_rec.bio = payload[:description]
      handle_rec.location = payload[:location]

      handle_rec.save
    else
      status = false
      payload = {max_id: -1}
    end

    TwitterRequestRecord.create request_type: :profile, cursor: payload[:max_id], status: status,
                                handle: handle_rec.handle
  end

  def get(handle_rec, command = :profile, opts = {})
    return nil unless [:profile, :tweets].include? command

    case command
    when :profile
      req = Twitter::REST::Request.new(@client, :get, "/1.1/users/show.json", {screen_name: handle_rec.handle})
    when :tweets
      req = Twitter::REST::Request.new(@client, :get, "/1.1/statuses/user_timeline.json", {screen_name: handle_rec.handle})
    end

    begin
      req.perform
    rescue Twitter::Error::NotFound => e
      {errors: 'Handle not found'}
    end
  end
end

class TwitterClient
  attr_reader :client
  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_SECRET"]
    end

    def thank_erik
      client.update "Thanks @sferik, I am tweeting with your gem! https://github.com/sferik/twitter"
    end

    def heartbeat
      s = "#{DateTime.now.strftime '%B %d / %H:%M:%S'}: gem heartbeat"
      client.update s
    end

    def followers(cursor: nil)
      opts = cursor ? {cursor: cursor} : {}
      client.followers 'suzboop', opts
    end
  end
end

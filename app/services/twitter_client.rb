class TwitterClient
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
end

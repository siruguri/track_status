class TwitterChannelPoster < ActiveJob::Base
  queue_as :twitter_channel_posts

  def perform(channel_post)
    @twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key    = Rails.application.secrets.twitter_consumer_key
      config.consumer_secret = Rails.application.secrets.twitter_consumer_secret
      config.access_token    = Rails.application.secrets.twitter_single_app_access_token
      config.access_token_secret = Rails.application.secrets.twitter_single_app_access_token_secret
    end
      
    a=@twitter_client.update(channel_post.message + " #{ENV['RAILS_HOSTNAME']}/#{channel_post.redirect_maps[0].src}")
    channel_post.total_post_count +=1
    channel_post.media_records.build({channel_id: a.id, channel_name: 'twitter'})

    channel_post.save
  end
end

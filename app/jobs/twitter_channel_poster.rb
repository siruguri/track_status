class TwitterChannelPoster < MediaChannelPoster
  def perform
    @twitter_client.update("This is a tweet now with #{@channel_post.url}, isn't it?!?")
  end
end

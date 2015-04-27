class ChannelPostsController < ApplicationController
  before_action :params_okay?, only: [:create]

  def new
    @channel_post = ChannelPost.new
  end
  
  def index
  end

  def create
    p = params[:channel_post]
    
    c = ChannelPost.new url: p[:url], message: p[:message]
    c.post_strategy = PostStrategy.default
    c.save

    TwitterChannelPoster.perform_later(c)
    @channel_posts = ChannelPost.all
    render :index
  end

  private
  def params_okay?
    if params[:channel_post][:url] and params[:channel_post][:message]
      true
    else
      render nothing: true, status: :bad_request
      false
    end
  end
end

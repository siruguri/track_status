class TwittersController < ApplicationController
  def input_handle
  end

  def bio
    t = TwitterProfile.find_or_create_by handle: params[:handle]
    TwitterFetcherJob.perform_later t

    redirect_to twitter_path(handle: t.handle)
  end

  def show
    @bio = TwitterProfile.find_by_handle params[:handle]
  end
end

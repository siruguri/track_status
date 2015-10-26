class TwittersController < ApplicationController
  def input_handle
  end

  def set_twitter_token
    params.each do |k, v|
      Rails.logger.debug("params[#{k}] is #{v}")
    end

    render nothing: true
  end
  
  def twitter_call
    if params[:commit] and params[:handle]
      @t = TwitterProfile.find_or_create_by handle: params[:handle]
      case params[:commit].downcase
      when 'get bio'
        bio
      when 'get tweets'
        tweets
      when 'word cloud'
        word_cloud
      end
      redirect_to twitter_path(handle: params[:handle])
    else
      flash[:error] = 'Something went wrong.'
      redirect_to twitter_input_handle_path
    end
  end
  def show
    if params[:handle]
      @bio = TwitterProfile.find_by_handle params[:handle]
      @tweets_list = TweetPacket.where(handle: params[:handle]).order(newest_tweet_at: :desc)
      word_cloud if @tweets_list.count > 0
    end
  end

  private
  def bio
    TwitterFetcherJob.perform_later @t # :bio is default
  end
  
  def tweets
    TwitterFetcherJob.perform_later @t, 'tweets'
  end

  def word_cloud
    doc = TweetPacket.where(handle: params[:handle]).all.map { |tp| tp.tweets_list.map { |t| t[:mesg] } }.flatten.join(' ')
    @word_cloud = TextStats::DocumentModel.new(doc).sorted_counts.inspect
  end
end

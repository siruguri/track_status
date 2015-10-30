class TwittersController < ApplicationController
  include TwitterAnalysis
  
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
      @app_token = set_app_tokens
      @t = TwitterProfile.find_or_create_by handle: params[:handle]
      case params[:commit].downcase
      when 'get bio'
        bio
      when /get .*tweets/i
        # Let's get the bio too, if we never did, when asking for tweets
        bio if !@t.member_since.present?
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
      @handle = params[:handle]
      @bio = TwitterProfile.find_by_handle params[:handle]
      @tweets_list = TweetPacket.where(handle: params[:handle]).order(newest_tweet_at: :desc)
      word_cloud if @tweets_list.count > 0
    end
  end

  private
  def bio
    TwitterFetcherJob.perform_later @t, 'bio', token: @app_token
  end
  
  def tweets
    TwitterFetcherJob.perform_later @t, 'tweets', token: @app_token
  end

  def word_cloud
    @tweets_count = 0

    doc_sets = separated_docs TweetPacket.where(handle: params[:handle]).all
    @tweets_count = doc_sets[:tweets_count]
    @orig_tweets_count = doc_sets[:orig_tweets_count]
    
    du = DocumentUniverse.last.universe

    o_dm = TextStats::DocumentModel.new(doc_sets[:orig_doc], twitter: true)
    a_dm = TextStats::DocumentModel.new(doc_sets[:all_doc], twitter: true)
    r_dm = TextStats::DocumentModel.new(doc_sets[:retweet_doc], twitter: true)
    o_dm.universe = du
    a_dm.universe = du
    r_dm.universe = du
    
    @orig_word_cloud = o_dm.sorted_counts
    @all_word_cloud = a_dm.sorted_counts
    @retweets_word_cloud = r_dm.sorted_counts
  end
    
  def set_app_tokens
    current_user ? current_user.token_hash : nil
  end
end
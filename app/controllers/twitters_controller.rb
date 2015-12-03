class TwittersController < ApplicationController
  include TwitterAnalysis
  before_action :set_handle_or_return, except: [:input_handle, :index, :batch_call]
  
  def input_handle
    @uncrawled_profiles = TwitterProfile.where('twitter_id is not null and handle is null').count
  end

  def index
    @handles_by_tweets = TweetPacket.joins(:user).group('twitter_profiles.handle').count
    @all_profiles = TwitterProfile.includes(:profile_stat).where('handle is not null')
  end
  
  def set_twitter_token
    params.each do |k, v|
      Rails.logger.debug("params[#{k}] is #{v}")
    end

    render nothing: true
  end

  def batch_call
    if !params["uncrawled-profiles"].nil?
      TwitterProfile.where('twitter_id is not null and handle is null').all.each do |profile|
        @t = profile
        bio
        tweets
      end
    end
    redirect_to twitter_input_handle_path
  end
  
  def twitter_call
    if params[:commit]
      @app_token = set_app_tokens
      @t = TwitterProfile.find_or_create_by handle: @handle
      case params[:commit].downcase
      when 'populate followers'
        followers
      when 'get bio'
        bio
      when /get older tweets/i
        # Let's get the bio too, if we never did, when asking for tweets
        bio if !@t.member_since.present?
        tweets
      when /get newer tweets/i
        tweets(direction: 'newer')
      end
      redirect_to twitter_path(handle: @handle)
    else
      flash[:error] = 'Something went wrong.'
      redirect_to twitter_input_handle_path
    end
  end
  
  def show
    @latest_tps = TweetPacket.where(twitter_id: @twitter_id).order(newest_tweet_at: :desc)
    @bio = TwitterProfile.find_by_handle @handle
    unless @latest_tps.empty?
      word_cloud
    end
  end

  private
  def set_handle_or_return
    if params[:handle].nil?
      render nothing: true, status: 422
    else
      @handle = params[:handle]
      @twitter_id = (tmp = TwitterProfile.find_by_handle(@handle)).nil? ? nil : tmp.twitter_id
    end
  end
  
  def followers
    TwitterFetcherJob.perform_later @t, 'followers', token: @app_token
  end
  def bio
    TwitterFetcherJob.perform_later @t, 'bio', token: @app_token
  end
  
  def tweets(opts = {})
    TwitterFetcherJob.perform_later @t, 'tweets', ({token: @app_token}.merge(opts))
  end

  def word_cloud
    @tweets_count = 0

    doc_sets = separated_docs @latest_tps.all
    @tweets_count = doc_sets[:tweets_count]
    @orig_tweets_count = doc_sets[:orig_tweets_count]
    
    du = DocumentUniverse.last.universe

    o_dm = TextStats::DocumentModel.new(doc_sets[:orig_doc], twitter: true)
    a_dm = TextStats::DocumentModel.new(doc_sets[:all_doc], twitter: true)
    r_dm = TextStats::DocumentModel.new(doc_sets[:retweet_doc], twitter: true)
    w_dm = TextStats::DocumentModel.new(crawled_web_documents(@latest_tps), as_html: true)
    
    o_dm.universe = du
    a_dm.universe = du
    r_dm.universe = du
    w_dm.universe = du
    
    @orig_word_cloud = o_dm.sorted_counts
    @orig_word_explanations = o_dm.explanations
    @all_word_cloud = a_dm.sorted_counts
    @retweets_word_cloud = r_dm.sorted_counts
    @webdocs_word_cloud = w_dm.sorted_counts
  end
    
  def set_app_tokens
    current_user ? current_user.token_hash : nil
  end

  def crawled_web_documents(tweet_packets)
    @webdocs_count = 0
    tweet_packets.joins(:web_articles).includes(:web_articles).
      where('web_articles.body is not null').map do |tp|
      tp.web_articles.map do |article|
        @webdocs_count += 1
        article.body
      end
    end.flatten.join ' '
  end
end

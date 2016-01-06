class TwittersController < ApplicationController
  include TwitterAnalysis
  before_action :set_handle_or_return, except: [:input_handle, :index, :batch_call, :authorize_twitter, :set_twitter_token]
  
  def input_handle
    @uncrawled_profiles = TwitterProfile.where('twitter_id is not null and handle is null').count
  end

  def index
    @handles_by_tweets = TweetPacket.joins(:user).group('twitter_profiles.handle').count

    # Filter down if there's a filter parameter
    if params[:followers_of] and !(leader = TwitterProfile.find_by_handle(params[:follower_of])).nil?
      @profiles_list = TwitterProfile.joins(:profile_followers).
                       where('handle is not null and profile_followers.leader_id = ?', leader.id)
    else
      @profiles_list = TwitterProfile.where('handle is not null')
    end

    @profiles_list = @profiles_list.joins(:profile_stat).includes(:profile_stat)
    @profiles_list_sorts = {tweets_count: @profiles_list.order(tweets_count: :desc),
                            tweets_retrieved: @profiles_list.order('(profile_stats.stats_hash_v2 ->> \'total_tweets\')::integer desc'),
                            last_known_tweet_time: @profiles_list.order(last_tweet_time: :desc)
                           }
  end

  def authorize_twitter
    if current_user
      client = OAuth::Consumer.new(
        Rails.application.secrets.twitter_consumer_key,
        Rails.application.secrets.twitter_consumer_secret,
        site: 'https://api.twitter.com'
      )
      
      request_token = client.get_request_token(oauth_callback: "#{request.protocol}#{request.host}/twitter/set_twitter_token")

      o = OauthTokenHash.create(source: 'twitter', user: current_user, request_token: request_token.to_yaml)
      redirect_to request_token.authorize_url
    else
      redirect_to new_user_session_path, notice: 'Need to be signed in locally'
    end      
  end
  
  def set_twitter_token
    if current_user
      if params[:oauth_token].present? and
        params[:oauth_verifier].present?
        latest_tokenhash = current_user.latest_token_hash('twitter')

        req_token = YAML.load(latest_tokenhash.request_token)
        client = OAuth::Consumer.new(
          Rails.application.secrets.twitter_consumer_key,
          Rails.application.secrets.twitter_consumer_secret,
          site: 'https://api.twitter.com'
        )

        acc_token = client.get_access_token(req_token, oauth_verifier: params[:oauth_verifier])

        latest_tokenhash.update_attributes(token: acc_token.token, secret: acc_token.secret)

        x = current_user
        TwitterClientWrapper.new(token: latest_tokenhash).rate_limited do
          account_settings! x
        end
      else
        render nothing: true
      end
    else
      render nothing: true
    end
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
      redirect_to twitter_path(handle: @t.handle)
    else
      flash[:error] = 'Something went wrong.'
      redirect_to twitter_input_handle_path
    end
  end
  
  def show
    @bio = @t

    if @t.twitter_id.present?
      @latest_tps = TweetPacket.where(twitter_id: @t.twitter_id).order(newest_tweet_at: :desc)
    else
      @latest_tps = []
    end
    
    unless @latest_tps.size == 0
      @universe_size = DocumentUniverse.count
      word_cloud
    end

    @g_set_title = @t.handle
  end

  private
  def set_handle_or_return
    if params[:handle].nil?
      render nothing: true, status: 422
    else
      @t = TwitterProfile.find_or_create_by handle: params[:handle]

      if @t.twitter_id.present?
        @identifier_fk_hash = {twitter_id: @t.twitter_id}
        @identifier = @t.twitter_id
      else
        @identifier_fk_hash = {handle: @t.handle}
        @identifier = @t.handle
      end
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
    
    o_dm = TextStats::DocumentModel.new(doc_sets[:orig_doc], twitter: true)
    a_dm = TextStats::DocumentModel.new(doc_sets[:all_doc], twitter: true)
    r_dm = TextStats::DocumentModel.new(doc_sets[:retweet_doc], twitter: true)
    w_dm = TextStats::DocumentModel.new(crawled_web_documents(@latest_tps), as_html: true)
    
    if @universe_size > 0
      du = DocumentUniverse.last.universe
      o_dm.universe = du
      a_dm.universe = du
      r_dm.universe = du
      w_dm.universe = du
    end
    
    @orig_word_cloud = o_dm.sorted_counts
    @orig_word_explanations = o_dm.explanations
    @all_word_cloud = a_dm.sorted_counts
    @retweets_word_cloud = r_dm.sorted_counts
    @webdocs_word_cloud = w_dm.sorted_counts
  end
    
  def set_app_tokens
    current_user ? current_user.latest_token_hash('twitter') : nil
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

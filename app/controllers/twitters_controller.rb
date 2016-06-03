class TwittersController < ApplicationController
  include TwitterAnalysis
  before_action :set_handle_or_return, only: [:twitter_call, :show]
  
  def input_handle
    @uncrawled_profiles = uncrawled_profiles_query.count
    if current_user and (p = current_user.twitter_profile).present?
      @user_has_profile = true
      @user_handle = p.handle
    end
  end

  def index
    @handles_by_tweets = Tweet.joins(:user).group('twitter_profiles.handle').count

    # Filter down if there's a filter parameter

    leader=nil
    if params[:followers_of]
      leader = TwitterProfile.find_by_handle params[:followers_of]
    end
    if !leader and current_user and current_user.twitter_profile and current_user.twitter_profile.handle
      leader = current_user.twitter_profile
    end
    if leader
      @profiles_list = leader.followers
    else
      @profiles_list = TwitterProfile.where('handle is not null')
    end

    @profiles_list = @profiles_list.joins(:profile_stat).includes(:profile_stat).where('profile_stats.stats_hash_v2 != ?', '{}')
    @profiles_list_sorts = {tweets_count: @profiles_list.order(tweets_count: :desc),
                            tweets_retrieved: @profiles_list.order('(profile_stats.stats_hash_v2 ->> \'total_tweets\')::integer desc'),
                            retweets_collected: @profiles_list.order('(profile_stats.stats_hash_v2 ->> \'retweet_aggregate\')::integer desc'),
                            retweeted_avg: @profiles_list.order('(profile_stats.stats_hash_v2 ->> \'retweeted_avg\')::float desc'),
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

      callback_str = twitter_set_twitter_token_url
      Rails.logger.debug ">>> #{callback_str}"

      request_token = client.get_request_token(oauth_callback: callback_str)

      o = OauthTokenHash.create(source: 'twitter', user: current_user, request_token: request_token.to_yaml)
      if Rails.env.test?
        redirect_to 'test.twitter.com/authorize'
      else
        redirect_to request_token.authorize_url
      end
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

        @remote_id = x.twitter_profile.handle
      else
        render nothing: true
      end
    else
      render nothing: true
    end
  end

  def batch_call
    @app_token = set_app_tokens
    
    if params["uncrawled-profiles"].present?
      uncrawled_profiles_query.all.each do |profile|
        bio profile
        tweets profile
      end
    end
    redirect_to twitter_input_handle_path
  end
  
  def twitter_call
    if params[:commit]
      @app_token = set_app_tokens

      case params[:commit].downcase
      when /populate.*followers/
        followers
      when /get.*bio/
        bio @t
      when /get.*older tweets/
        # Let's get the bio too, if we never did, when asking for tweets
        bio @t if !@t.member_since.present?
        tweets(@t, direction: 'older')
      when /get newer tweets/
        tweets(@t, direction: 'newer')
      end
      redirect_to twitter_path(handle: @t.handle)
    else
      flash[:error] = 'Something went wrong.'
      redirect_to twitter_input_handle_path
    end
  end
  
  def show
    @bio = @t
    @latest_tweets = Tweet.where(user: @t).order(tweeted_at: :desc)
    
    unless @latest_tweets.count == 0
      @universe_size = DocumentUniverse.count
      word_cloud
    end

    @g_set_title = @t.handle
  end

  private
  def uncrawled_profiles_query
    TwitterProfile.includes(:tweets).
      joins('left OUTER JOIN tweets ON tweets.twitter_id = twitter_profiles.twitter_id').where('tweets.id is null')    
  end
  
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
  def bio(t)
    TwitterFetcherJob.perform_later t, 'bio', token: @app_token
  end
  def tweets(t, opts = {})
    TwitterFetcherJob.perform_later t, 'tweets', ({token: @app_token}.merge(opts))
  end

  def word_cloud
    @tweets_count = 0

    doc_sets = separated_docs @latest_tweets.all
    @tweets_count = doc_sets[:tweets_count]
    @orig_tweets_count = doc_sets[:orig_tweets_count]

    o_dm = TextStats::DocumentModel.new(doc_sets[:orig_doc], twitter: true)
    a_dm = TextStats::DocumentModel.new(doc_sets[:all_doc], twitter: true)
    r_dm = TextStats::DocumentModel.new(doc_sets[:retweet_doc], twitter: true)
    w_dm = TextStats::DocumentModel.new(crawled_web_documents(@t), as_html: true)
    
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

  def crawled_web_documents(profile)
    @webdocs_count = 0
    WebArticle.where('web_articles.body is not null and twitter_profile_id = ?', profile.id).all.map do |article|
      @webdocs_count += 1
      article.body
    end.join ' '
  end
end

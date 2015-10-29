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
      @app_token = set_app_tokens
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
    TwitterFetcherJob.perform_later @t, 'bio', token: @app_token
  end
  
  def tweets
    TwitterFetcherJob.perform_later @t, 'tweets', token: @app_token
  end

  def word_cloud
    @tweets_count = 0

    doc_sets = separated_docs TweetPacket.where(handle: params[:handle]).all
    @tweets_count = doc_sets[:tweets_count]
    
    du = TextStats::DocumentUniverse.new
    TwitterProfile.all.each do |profile|
      if profile.tweet_packets.size > 0
        du.add TextStats::DocumentModel.new(separated_docs(profile.tweet_packets.all)[:all_doc])
      end
    end

    o_dm = TextStats::DocumentModel.new(doc_sets[:orig_doc], twitter: true)
    a_dm = TextStats::DocumentModel.new(doc_sets[:all_doc], twitter: true)
    o_dm.universe = du
    a_dm.universe = du
    
    @orig_word_cloud = o_dm.sorted_counts
    @all_word_cloud = a_dm.sorted_counts
  end
  
  def separated_docs(tweet_packet_list)    
    tweet_packet_list.inject({tweets_count: 0}) do |memo1, tp|
      tp.tweets_list.inject(memo1) do |memo2, t|
        # Store original tweets in one key...
        if t[:retweeted_status].nil?
          memo2[:orig_doc] = "#{memo2[:orig_doc]} #{t[:mesg]}"
          store_mesg = t[:mesg]
        else
          store_mesg = t[:retweeted_status][:text]
        end

        # And all tweets in another
        memo2[:all_doc] = "#{memo2[:all_doc]} #{store_mesg}"
        memo2
      end

      memo1[:tweets_count] += tp.tweets_list.size
      memo1
    end
  end    
  
  def set_app_tokens
    current_user ? current_user.token_hash : nil
  end
end

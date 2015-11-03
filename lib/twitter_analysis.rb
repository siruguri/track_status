module TwitterAnalysis
  def separated_docs(tweet_packet_list_or_tweets_list)
    return unless [Array, TweetPacket::ActiveRecord_Relation].include?(TweetPacket::ActiveRecord_Relation)

    # If we want aggregate stats, we should have passed in an Array of TweetPackets
    return docs_only(tweet_packet_list_or_tweets_list) if tweet_packet_list_or_tweets_list.first.is_a? Hash

    tweet_packet_list = tweet_packet_list_or_tweets_list
    tweet_packet_list.inject({tweets_count: 0, orig_tweets_count: 0}) do |memo1, tp|
      tp.tweets_list.inject(memo1) do |memo2, t|
        # Store original tweets in one key...
        if t[:retweeted_status].nil?
          memo2[:orig_doc] = "#{memo2[:orig_doc]} #{t[:mesg]}"
          store_mesg = t[:mesg]
          memo1[:orig_tweets_count] += 1
        else
          memo2[:retweet_doc] = "#{memo2[:retweet_doc]} #{t[:retweeted_status][:text]}"
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

  def docs_only(tweets_list)
    tweets_list.inject({}) do |memo, t|
        # Store original tweets in one key...
        if t[:retweeted_status].nil?
          memo[:orig_doc] = "#{memo[:orig_doc]} #{t[:mesg]}"
          store_mesg = t[:mesg]
        else
          memo[:retweet_doc] = "#{memo[:retweet_doc]} #{t[:retweeted_status][:text]}"
          store_mesg = t[:retweeted_status][:text]
        end

        # And all tweets in another
        memo[:all_doc] = "#{memo[:all_doc]} #{store_mesg}"
        memo
      end
  end
end

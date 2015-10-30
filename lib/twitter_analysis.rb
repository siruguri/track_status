module TwitterAnalysis
  def separated_docs(tweet_packet_list)    
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
end  

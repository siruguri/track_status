module Ajax
  class Actions
    def self.perform(idx, opts = {})
      executed = false
      case idx
      when 1
        list = []
        if t = opts[:user]&.twitter_profile
          list = TwitterManagement::Feed.refresh_feed(t).join '; '
          Response.update list
          executed = true
        end
      when 2
        tweet_id = opts[:data][0]
        j = TwitterFetcherJob.perform_later opts[:user]&.twitter_profile, 'retweet', {tweet_id: tweet_id}
        Response.update "retweet scheduled"
      end

      executed
    end    

    def self.valid_ids
      [1, 2]
    end

    def self.last_known_response
      Response.last_known_response
    end
  end
end

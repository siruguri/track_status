class TwitterFetcherJob < ActiveJob::Base
  queue_as :twitter_fetches

  def perform(handle_rec, command='bio', opts = {})
    TwitterClientWrapper.new(opts).rate_limited do
      case command
      when 'retweet'
        retweet! handle_rec, opts
      when 'tweet'
        tweet! handle_rec, opts
      when 'followers'
        # Will not use cursoring
        fetch_followers! handle_rec
      when 'my_friends'
        fetch_my_friends! handle_rec
      when 'bio'
        fetch_profile! handle_rec
      when 'tweets'
        if opts[:relative_id].nil?
          # The default behavior is to get the timeline that's more recent than the most recent tweet or that's older
          # than the oldest know tweets.
          t = if opts[:direction].try(:to_sym) == :older
                handle_rec.tweets.oldest
              else
                handle_rec.tweets.newest
              end
          opts[:relative_id] = t&.tweet_id || -1
        end
        
        fetch_tweets! handle_rec, opts
      end
    end
  end
end

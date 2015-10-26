class TwitterFetcherJob < ActiveJob::Base
  queue_as :twitter_fetches

  def perform(handle_rec, command='bio')
    TwitterClientWrapper.new.rate_limited do
      case command
      when 'bio'
        fetch_profile! handle_rec
      when 'tweets'
        t = TweetPacket.where(handle: handle_rec.handle).order(oldest_tweet_at: :asc).limit(1)
        if t.count == 0
          fetch_tweets! handle_rec
        else
          fetch_tweets! handle_rec, t.first
        end
      end
    end
  end
end

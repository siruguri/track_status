class TwitterFetcherJob < ActiveJob::Base
  queue_as :twitter_fetches

  def perform(handle_rec, command='bio', opts = {})
    token = opts[:token]
    TwitterClientWrapper.new(token: token).rate_limited do
      case command
      when 'bio'
        fetch_profile! handle_rec
      when 'tweets'
        t = TweetPacket.where(handle: handle_rec.handle).order(oldest_tweet_at: :asc).limit(1)
        fetch_tweets! handle_rec, t.first
      end
    end
  end
end

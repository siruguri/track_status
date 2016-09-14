class TwitterFetcherJob < ActiveJob::Base
  queue_as :twitter_fetches

  def perform(handle_rec, command='bio', opts = {})
    TwitterClientWrapper.new(token: opts[:token]).rate_limited do
      case command
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
        # The default behavior is to get the timeline that's most recent.
        t = if opts[:direction].try(:to_sym) == :older
              handle_rec.tweets.oldest
            else
              handle_rec.tweets.newest
            end
        fetch_tweets! handle_rec, t, opts
      end
    end
  end
end

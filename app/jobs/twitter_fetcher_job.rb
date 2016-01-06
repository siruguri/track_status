class TwitterFetcherJob < ActiveJob::Base
  queue_as :twitter_fetches

  def perform(handle_rec, command='bio', opts = {})
    TwitterClientWrapper.new(token: opts[:token]).rate_limited do
      case command
      when 'followers'
        fetch_followers! handle_rec
      when 'bio'
        fetch_profile! handle_rec
      when 'tweets'
        t = if opts[:direction].nil? or opts[:direction].to_sym == :older
              handle_rec.tweets.oldest
            else
              handle_rec.tweets.newest
            end
        fetch_tweets! handle_rec, t, opts
      end
    end
  end
end

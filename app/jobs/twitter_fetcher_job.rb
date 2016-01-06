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
        if opts[:direction].nil? or opts[:direction].to_sym == :older
          order_logic = {oldest_tweet_at: :asc}
        else
          order_logic = {newest_tweet_at: :desc}
        end
        t = handle_rec.tweet_packets.order(order_logic).limit(1)
        fetch_tweets! handle_rec, t.first, opts
      end
    end
  end
end

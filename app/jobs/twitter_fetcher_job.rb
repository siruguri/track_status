class TwitterFetcherJob < ActiveJob::Base
  queue_as :twitter_fetches

  def perform(handle_rec)
    TwitterClientWrapper.new.rate_limited do
      fetch_profile! handle_rec
    end
  end
end

module TwitterManagement
  class Feed
    def self.refresh_feed(profile)
      return unless profile.is_a?(TwitterProfile)
      refresh_list = []
      now = Time.now

      if Tweet.top_of_feed(profile) < (now - 24.hours)
        profile.friends.where('last_tweet_time is not null and last_tweet_time > ?', DateTime.now - 100.days).
          order(last_tweet_time: :desc).each do |profile|
          TwitterFetcherJob.perform_later profile, 'tweets', token: @app_token
          refresh_list << "#{profile.handle} (#{(now - profile.last_tweet_time)/(60*60*24)})"
        end
      end

      refresh_list
    end
  end
end

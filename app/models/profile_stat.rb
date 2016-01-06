class ProfileStat < ActiveRecord::Base
  belongs_to :twitter_profile

  def stats_hash
    # Backwards compatibility
    stats_hash_v2
  end
  
  def self.update_all
    TwitterProfile.includes(:tweets).where('handle is not null').each do |profile|
      stat_rec = (profile.profile_stat || create(twitter_profile_id: profile.id))
      update_followers profile, stat_rec
      update_tweet_counts profile, stat_rec
    end
  end

  private
  def self.update_followers(profile, stat_rec)
    follower_count = ProfileFollower.where(leader: profile).count
    stat_rec.stats_hash[:follower_count] = follower_count
    stat_rec.save
  end
  
  def self.update_tweet_counts(profile, stat_rec)
    retweet_agg = 0

    # Count total tweets in db, and total retweet count across all these
    # tweets.

    retweeted_mesgs = 1
    profile.tweets.each do |tweet_rec|
      # If this is an original message that has been re-tweeted, we want to know!
      tweet_deets = tweet_rec.tweet_details
      if tweet_deets['retweeted_status'].nil? and
        tweet_deets['retweet_count'].try(:>, 0) == true
        retweet_agg += tweet_deets['retweet_count']
        retweeted_mesgs += 1
      end
    end

    stat_rec.stats_hash[:total_tweets] = profile.tweets.count
    stat_rec.stats_hash[:retweet_aggregate] = retweet_agg
    stat_rec.stats_hash[:retweeted_avg] = retweet_agg.to_f/retweeted_mesgs
    stat_rec.save
  end
end

class ProfileStat < ActiveRecord::Base
  belongs_to :twitter_profile
  serialize :stats_hash, Hash
  
  def self.update_all
    TwitterProfile.where('handle is not null').includes(:tweet_packets, :profile_stat).each do |profile|
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
    tweets_ct = retweet_agg = 0

    # Count total tweets in db, and total retweet count across all these
    # tweets.
    profile.tweet_packets.inject(0) do |tweets_ct, tp_rec|
      tweets_ct += tp_rec.tweets_list.size

      retweet_agg += tp_rec.tweets_list.inject(0) do |retweet_count, tweet_hash|
        if tweet_hash[:retweet_count].nil?
          binding.pry
        end
        
        retweet_count += tweet_hash[:retweet_count]
      end
    end

    stat_rec.stats_hash[:total_tweets] = tweets_ct
    stat_rec.stats_hash[:retweet_aggregate] = retweet_agg
    stat_rec.save
  end
end

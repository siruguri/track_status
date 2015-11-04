class ProfileStat < ActiveRecord::Base
  belongs_to :twitter_profile
  serialize :stats_hash, Hash
  
  def self.update_all
    update_tweet_counts
  end

  private
  def self.update_tweet_counts
    TwitterProfile.includes(:tweet_packets, :profile_stat).each do |profile|
      stat_rec = (profile.profile_stat || create(twitter_profile_id: profile.id))
      stat_rec.stats_hash[:total_tweets] = profile.tweet_packets.inject(0) do |ct, tp_rec|
        ct += tp_rec.tweets_list.size
      end

      stat_rec.save
    end
  end
end

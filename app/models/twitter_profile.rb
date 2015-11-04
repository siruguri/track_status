class TwitterProfile < ActiveRecord::Base
  has_many :tweet_packets, foreign_key: :handle, primary_key: :handle
  has_one :profile_stat
  
  serialize :last_tweet, Hash
end

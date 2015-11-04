class TwitterProfile < ActiveRecord::Base
  has_many :tweet_packets, foreign_key: :handle, primary_key: :handle

  serialize :last_tweet, Hash
end

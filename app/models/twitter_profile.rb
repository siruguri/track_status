class TwitterProfile < ActiveRecord::Base
  has_many :tweets, foreign_key: :twitter_id, primary_key: :twitter_id
  has_one :profile_stat

  has_many :profile_followers, foreign_key: :leader_id, dependent: :destroy
  has_many :followers, through: :profile_followers, class_name: 'TwitterProfile', primary_key: :leader_id,
           foreign_key: :follower_id

  belongs_to :user
end

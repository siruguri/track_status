class TweetPacket < ActiveRecord::Base
  serialize :tweets_list, Array

  belongs_to :user, class_name: 'TwitterProfile', primary_key: 'handle', foreign_key: 'handle'

  def first
    tweets_list.first
  end

  def last
    tweets_list.last
  end
end

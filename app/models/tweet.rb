class Tweet < ActiveRecord::Base
  has_many :web_articles
  belongs_to :user, class_name: 'TwitterProfile', primary_key: 'twitter_id', foreign_key: 'twitter_id'

  def self.latest_by_friends(user)
    joins(user: :graph_connections_head).where('graph_connections.follower_id = ?', user.twitter_profile.id).order(tweeted_at: :desc)
  end
  
  def is_retweet?
    self.tweet_details['retweeted_status'].try(:size).present?
  end
  
  def self.latest
    order(tweeted_at: :desc).first
  end
  Tweet.singleton_class.send(:alias_method, :newest, :latest) 

  def self.oldest
    order(tweeted_at: :asc).first
  end
end

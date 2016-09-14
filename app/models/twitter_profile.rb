class TwitterProfile < ActiveRecord::Base
  has_many :tweets, foreign_key: :twitter_id, primary_key: :twitter_id, dependent: :destroy
  has_one :profile_stat, dependent: :destroy

  has_many :twitter_request_records, foreign_key: :handle, primary_key: :handle
  has_many :graph_connections_head, class_name: 'GraphConnection',
           dependent: :destroy, foreign_key: :leader_id, inverse_of: :leader
  has_many :graph_connections_tail, class_name: 'GraphConnection',
           dependent: :destroy, foreign_key: :follower_id, inverse_of: :follower
  has_many :friends, through: :graph_connections_tail, source: :leader, class_name: 'TwitterProfile'
  has_many :followers, through: :graph_connections_head, source: :follower, class_name: 'TwitterProfile'
  
  serialize :word_cloud, Hash
  belongs_to :user

  after_create :create_stat
  private
  def create_stat
    # blank profile stat for later batch processing
    p = ProfileStat.new twitter_profile_id: self.id
    p.save
  end
end

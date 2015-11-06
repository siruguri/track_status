class ProfileFollower < ActiveRecord::Base
  belongs_to :leader, class_name: 'TwitterProfile'
  belongs_to :follower, class_name: 'TwitterProfile'
end

require 'test_helper'

class TweetPacketTest < ActiveSupport::TestCase
  test 'keys work' do
    joined_profile = tweet_packets(:tweet_packet_1).user
    assert_equal twitter_profiles(:twitter_profile_1).id, joined_profile.id    
  end
end

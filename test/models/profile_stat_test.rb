require 'test_helper'
class ProfileStatTest < ActiveSupport::TestCase
  test '::update_all' do
    assert_equal 455, ProfileStat.find_by_twitter_profile_id(twitter_profiles(:twitter_profile_1).id).stats_hash['retweet_aggregate']
    assert_difference('ProfileStat.count', 1) do
      ProfileStat.update_all
    end

    # The fixtures contain a new orig message that has been retweeted 5 times.
    assert_equal 460,
                 ProfileStat.find_by_twitter_profile_id(twitter_profiles(:twitter_profile_1).id).stats_hash_v2['retweet_aggregate']
  end
end

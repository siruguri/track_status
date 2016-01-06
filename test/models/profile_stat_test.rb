require 'test_helper'
class ProfileStatTest < ActiveSupport::TestCase
  test '::update_all' do
    assert_equal 455, ProfileStat.find_by_twitter_profile_id(twitter_profiles(:twitter_profile_1).id).stats_hash['retweet_aggregate']
    assert_difference('ProfileStat.count', TwitterProfile.where('handle is not null').count - ProfileStat.count) do
      ProfileStat.update_all
    end

    assert_equal 2, ProfileStat.find_by_twitter_profile_id(twitter_profiles(:twitter_profile_1).id).stats_hash['retweet_aggregate']
  end
end

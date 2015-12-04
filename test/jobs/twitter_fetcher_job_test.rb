require 'test_helper'
class TwitterFetcherJobTest < ActiveSupport::TestCase
  def setup
    set_net_stubs
  end
  
  test ':bio job works with valid handle' do
    refute_match /Oakland/, twitter_profiles(:twitter_profile_1).location
    TwitterFetcherJob.perform_now twitter_profiles(:twitter_profile_1)
    assert_match /Oakland/, twitter_profiles(:twitter_profile_1).location    
  end

  test 'job fails gracefully with invalid handle' do
    TwitterFetcherJob.perform_now twitter_profiles(:nota_twitter_profile)

    refute TwitterRequestRecord.last.status?
  end

  describe ":tweets job" do
    it 'works when profile has twitter id' do
      assert_difference('TweetPacket.count', 1) do
        TwitterFetcherJob.perform_now twitter_profiles(:twitter_profile_1), 'tweets'
      end

      t = TweetPacket.last
      assert_equal 3, t.tweets_list.size
      assert_equal twitter_profiles(:twitter_profile_1).twitter_id, t.twitter_id
      assert_equal 1, t.twitter_id
    end

    it 'works when profile does not have twitter id' do
      assert_difference('TweetPacket.count', 1) do
        TwitterFetcherJob.perform_now twitter_profiles(:no_id_profile), 'tweets'
      end
    end
  end
  
  test ":followers works" do
    assert_difference('TwitterProfile.count', 2) do
      TwitterFetcherJob.perform_now twitter_profiles(:twitter_profile_1), 'followers'
    end
    t = TwitterProfile.last
    assert_equal 8400, t.twitter_id

    assert_equal 2, ProfileFollower.count
  end
end

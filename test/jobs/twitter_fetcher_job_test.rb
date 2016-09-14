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
      assert_difference('Tweet.count', 3) do
        TwitterFetcherJob.perform_now twitter_profiles(:twitter_profile_1), 'tweets'
      end

      assert_equal twitter_profiles(:twitter_profile_1).id, Tweet.last.user.id
      assert_equal 239413543487819778, Tweet.last.tweet_id
    end

    it 'works when profile does not have twitter id' do
      assert_difference('Tweet.count', 4) do
        TwitterFetcherJob.perform_now twitter_profiles(:no_id_profile), 'tweets'
      end
    end
  end
  
  describe ":followers" do
    it 'works without existing followers' do
      assert_difference('TwitterProfile.count', 2) do
        TwitterFetcherJob.perform_now twitter_profiles(:twitter_profile_1), 'followers'
      end
      t = TwitterProfile.last
      assert_equal 8400, t.twitter_id
      
      assert_equal 2, GraphConnection.where(leader: twitter_profiles(:twitter_profile_1)).count

      assert_equal 1479414865424994218, TwitterRequestRecord.last.cursor
      assert_equal "follower_ids", TwitterRequestRecord.last.request_type
    end
    
    it 'works with existing followers' do
      assert_difference('TwitterProfile.count', 3) do
        TwitterFetcherJob.perform_now twitter_profiles(:existing_followers), 'followers'
      end
    end
  end
end

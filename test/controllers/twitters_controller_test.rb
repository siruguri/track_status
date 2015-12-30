require 'test_helper'
class TwittersControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper
  def setup
    set_net_stubs
  end
  
  test 'routing' do
    assert_routing({method: :post, path: '/twitter/twitter_call', handle: 'xyz'},
                   {controller: 'twitters', action: 'twitter_call'})
    assert_routing '/twitter/input_handle', {controller: 'twitters', action: 'input_handle'}
  end

  test 'errors' do
    post :twitter_call, {commit: 'Hack it', handle: twitter_profiles(:twitter_profile_1).handle}
    assert_redirected_to twitter_path(handle: 'twitter_handle')

    post :twitter_call, {commit: 'Hack it'}
    assert_equal 422, response.status

    post :twitter_call, {handle: twitter_profiles(:twitter_profile_1).handle}
    assert_redirected_to twitter_input_handle_path
    assert_match /went.wrong/i, flash[:error]
  end

  test '#index' do
    get :index

    assert_select('li.twitter-profile', ProfileStat.count*3) do |lis|
      # The first one's in the nav bar
      assert_operator lis.select { |l| /Tue, Mar 03, 12:17:04/.match l.text}.size, :>, 0
    end
  end
  
  test '#show' do
    get :show, {handle: twitter_profiles(:twitter_profile_1).handle}
    
    assert_match /ee bee/, response.body
    assert_match /\d.*retrieved/i, response.body

    assert_equal [["bear", 2], ["cheetah", 2]], assigns(:orig_word_cloud)
    assert_equal [["cheetah", 2], ["bear", 2], ["cat", 2.0/1.042], ["dog", 2.0/1.042]], assigns(:all_word_cloud)
  end

  test '#input_handle' do
    get :input_handle
    assert_match /Get bio/, response.body
  end

  test '#bio' do
    assert_enqueued_with(job: TwitterFetcherJob) do
      post :twitter_call, {commit: 'Get bio', handle: twitter_profiles(:twitter_profile_1).handle}
    end

    assert_redirected_to twitter_path(handle: twitter_profiles(:twitter_profile_1).handle)
  end

  test '#bio with unknown twitter profile' do
    assert_difference('TwitterProfile.count', 1) do
      post :twitter_call, {commit: "Get bio", handle: 'nosuch_handle'}
    end
  end

  describe 'getting tweets' do
    describe 'when authenticated' do
      before do
        devise_sign_in users(:user_1)
      end

      it 'uses access tokens' do
        perform_enqueued_jobs do
          post :twitter_call, {commit: 'Get older tweets', handle: 'twitter_handle'}
        end
      end
    end

    describe 'unauthenticated' do
      before do
        devise_sign_out users(:user_1)
      end

      it 'uses single app access tokens' do
        perform_enqueued_jobs do
          post :twitter_call, {commit: 'Get older tweets', handle: 'twitter_handle'}
        end

        perform_enqueued_jobs do
          post :twitter_call, {commit: 'Get newer tweets', handle: 'twitter_handle'}
        end
        assert_equal 'newer_response_id', TweetPacket.last.tweets_list[0][:id]
      end
    end  
  end
end

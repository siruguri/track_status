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
    assert_template :input_handle

    post :twitter_call, {commit: 'Hack it'}
    assert_equal 422, response.status

    post :twitter_call, {handle: twitter_profiles(:twitter_profile_1).handle}
    assert_redirected_to twitter_input_handle_path
    assert_match /went.wrong/i, flash[:error]
  end

  test '#set_twitter_token' do
    devise_sign_in users(:user_2)

    t =  OAuth::Token.new('accesstoken', 'accesssecret')
    OAuth::Consumer.any_instance.stubs(:get_access_token).returns t

    assert_difference('TwitterProfile.count', 1) do
      get :set_twitter_token, {oauth_token: 'oauthtoken', oauth_verifier: 'oauth_verifier'}
    end

    assert_equal users(:user_2).id, TwitterProfile.last.user_id
    # This is in the fixture file
    assert_equal 'theSeanCook', TwitterProfile.last.handle
    assert_match /theSeanCook/, response.body
  end
  
  describe '#index' do
    it "return all profiles without a restriction" do
      get :index
      assert_select('.row.handle-details', ProfileStat.count*4)
    end

    it "users followers_of restriction" do
      get :index, { followers_of: twitter_profiles(:leader_profile).handle }
      assert_select('.row.handle-details', 4)
    end
  end
  
  test '#show' do
    get :show, {handle: twitter_profiles(:twitter_profile_1).handle}
    
    assert_match /ee bee/, response.body
    assert_match /\d.*retrieved/i, response.body

    assert_equal [["bear", 2], ["cheetah", 2]], assigns(:word_cloud)[:orig_word_cloud]
  end

  describe '#input_handle' do
    it 'works without login' do
      get :input_handle
      assert_match /Get bio/, response.body
    end

    it 'works with login' do
      devise_sign_in users(:user_2)
      get :input_handle
      assert assigns(:user_has_profile)
    end
  end

  test '#bio' do
    assert_enqueued_with(job: TwitterFetcherJob) do
      post :twitter_call, {commit: 'Get bio', handle: twitter_profiles(:twitter_profile_1).handle}
    end

    assert_template :input_handle
  end

  test '#my_feed' do
    assert_enqueued_with(job: TwitterFetcherJob) do
      post :twitter_call, {commit: 'whom follow', handle: twitter_profiles(:twitter_profile_1).handle}
    end

    assert_template :input_handle
  end
  
  test '#bio with unknown twitter profile' do
    assert_difference('TwitterProfile.count', 1) do
      post :twitter_call, {commit: "Get bio", handle: 'nosuch_handle'}
    end
  end

  describe 'getting tweets' do
    describe 'when authenticated' do
      before do
        devise_sign_in users(:user_with_profile)
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
        assert_difference('Tweet.count', 3) do
          perform_enqueued_jobs do
            post :twitter_call, {commit: 'Get older tweets', handle: 'twitter_handle'}
          end
        end

        perform_enqueued_jobs do
          post :twitter_call, {commit: 'Get newer tweets', handle: 'twitter_handle'}
        end

        # Look in fixture file
        assert_equal 239413543487819778, Tweet.last.tweet_id
      end
    end
  end
  
  describe 'twitter oauth' do
    it 'works' do
      devise_sign_in users(:user_2)
      get :authorize_twitter
      assert_redirected_to 'test.twitter.com/authorize'
    end
  end

  describe 'schedule' do
    it 'needs login for getting and posting' do
      get :schedule
      assert_redirected_to new_user_session_path
      post :schedule
      assert_redirected_to new_user_session_path

      devise_sign_in users(:user_1)
      put :schedule
      assert_redirected_to twitter_input_handle_path
    end
  
    describe 'signed in' do
      before do
        devise_sign_in users(:user_with_profile)
      end
      it 'renders form' do
        get :schedule
        assert_template :schedule
      end

      it 'sets up jobs' do
        assert_enqueued_with(job: DripTweetJob) do
          post :schedule, twitter_schedule: {messages: ['a', 'b', 'c']}, uri: 'http://www.myuri.com'
        end
      end
    end
  end
end

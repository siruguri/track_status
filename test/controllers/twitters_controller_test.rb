require 'test_helper'
class TwittersControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper
  include Devise::Test::ControllerHelpers
  
  def setup
    set_net_stubs
  end

  test '#feed' do
    sign_in users(:user_2)
    get :feed
    sign_out :user

    # Trigger time to wait logic and paging logic simultaneously
    sign_in (u = users(:user_with_profile))

    # this is a graph connection
    generate_new_tweets twitter_profiles(:recent_leader_profile), 15

    # A bookmark is created
    assert_difference('Config.count') do
      get :feed, page: 2
    end

    # Two existing tweets + 15 = 17.
    assert_equal 7, assigns(:feed_list).size

    # Getting the first page won't change the bookmark
    get :feed, page: 1
    assert_equal 2, Config.last.config_value.to_i
    sign_out :user
  end
  
  test 'routing' do
    assert_routing({method: :post, path: '/twitter/twitter_call', handle: 'xyz'},
                   {controller: 'twitters', action: 'twitter_call'})
    assert_routing '/twitter/input_handle', {controller: 'twitters', action: 'input_handle'}
  end

  test 'errors' do
    post :twitter_call, {commit: 'Hack it', handle: twitter_profiles(:twitter_profile_1).handle}
    assert_redirected_to twitter_input_handle_path

    post :twitter_call, {commit: 'Hack it'}
    assert_equal 422, response.status

    post :twitter_call, {handle: twitter_profiles(:twitter_profile_1).handle}
    assert_redirected_to twitter_input_handle_path
    assert_match /went.wrong/i, flash[:error]
  end

  describe '#set_twitter_token' do
    it 'bumps up against uniqueness constraints for users' do
      devise_sign_in users(:user_2)

      t =  OAuth::Token.new('accesstoken-set-in-test', 'accesssecret')
      OAuth::Consumer.any_instance.stubs(:get_access_token).returns t

      get :set_twitter_token, {oauth_token: 'oauthtoken', oauth_verifier: 'oauth_verifier'}
      assert_match /claim/, TwitterRequestRecord.last.status_message
    end

    it 'works otherwise' do
      devise_sign_in users(:user_wo_profile)

      t =  OAuth::Token.new('accesstoken-set-in-test-for-new-profile', 'accesssecret')
      OAuth::Consumer.any_instance.stubs(:get_access_token).returns t

      assert_difference('TwitterProfile.count', 1) do
        get :set_twitter_token, {oauth_token: 'oauthtoken', oauth_verifier: 'oauth_verifier'}
      end

      assert_equal users(:user_wo_profile).id, TwitterProfile.last.user_id
      # This is in the fixture file
      assert_equal 'theSeanCook', TwitterProfile.last.handle
      assert_match /theSeanCook/, response.body
    end
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

    assert_redirected_to twitter_input_handle_path
  end

  test '#my_friends' do
    assert_enqueued_with(job: TwitterFetcherJob) do
      post :twitter_call, {commit: 'whom follow', handle: twitter_profiles(:twitter_profile_1).handle}
    end

    assert_redirected_to twitter_input_handle_path
  end
  
  test '#refresh_feed' do
    post :twitter_call, {commit: 'refresh feed', handle: twitter_profiles(:twitter_profile_1).handle}
    assert (enqueued_jobs.size == 0 or enqueued_jobs.select { |j| j[:job] == TwitterFetcherJob }.size == 0)

    devise_sign_in users(:user_2) # users tp 1
    assert_enqueued_with(job: TwitterFetcherJob) do
      post :twitter_call, {commit: 'refresh feed'}
    end
    # tp_1 has two friends, one tweeted 500 days ago though
    assert_equal 1, enqueued_jobs.select { |j| j[:job] == TwitterFetcherJob }.size
    assert_redirected_to twitter_input_handle_path
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
        assert_equal 1111911239413, Tweet.last.tweet_id
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

        assert_equal users(:user_with_profile).latest_token_hash.token,
                     GlobalID::Locator.locate(enqueued_jobs[0][:args][2]['token']['_aj_globalid']).token
      end
    end
  end

  private
  def generate_new_tweets(profile, num)
    num.times.each do |i|
      t = Tweet.new tweet_id: "8810280192#{i}", tweeted_at: DateTime.now - 1.day - i.minutes,
                    tweet_details: ({entities: {}, text: 'hello'}), mesg: 'hello', twitter_id: profile.twitter_id
      t.save
    end
  end
end

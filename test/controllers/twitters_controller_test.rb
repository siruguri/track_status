require 'test_helper'
class TwittersControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper
  
  test 'routing' do
    assert_routing({method: :post, path: '/twitter/twitter_call', handle: 'xyz'},
                   {controller: 'twitters', action: 'twitter_call'})
    assert_routing '/twitter/input_handle', {controller: 'twitters', action: 'input_handle'}
  end

  test '#show' do
    get :show, {handle: twitter_profiles(:twitter_profile_1).handle}
    
    assert_match /ee bee/, response.body
    assert_match /retrieved.*1/i, response.body
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
end

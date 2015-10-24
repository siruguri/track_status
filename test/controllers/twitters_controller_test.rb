require 'test_helper'
class TwittersControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper
  
  test 'routing' do
    assert_routing({method: :post, path: '/twitter/bio', handle: 'xyz'}, {controller: 'twitters', action: 'bio'})
    assert_routing '/twitter/input_handle', {controller: 'twitters', action: 'input_handle'}
  end

  test '#show' do
    get :show, {handle: twitter_profiles(:twitter_profile_1).handle}
    assert_match /ee bee/, response.body
  end

  test '#input_handle' do
    get :input_handle
    assert_match /Get bio/, response.body
  end

  test '#bio' do
    assert_enqueued_with(job: TwitterFetcherJob) do
      post :bio, {handle: twitter_profiles(:twitter_profile_1).handle}
    end

    assert_redirected_to twitter_path(handle: twitter_profiles(:twitter_profile_1).handle)
  end

  test '#bio with unknown twitter profile' do
    assert_difference('TwitterProfile.count', 1) do
      post :bio, {handle: 'nosuch_handle'}
    end
  end
end

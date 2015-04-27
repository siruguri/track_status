require 'test_helper'
require 'webmock/minitest'

class ChannelPostsControllerTest < ActionController::TestCase
  # Tests for Readability controller 
  include ActiveJob::TestHelper
  
  describe 'Routing' do
    it 'Lets a post form be created' do
      assert_routing '/channel_posts/new', {controller: 'channel_posts', action: 'new'}
    end
    
    it 'Lets a post be created' do
      assert_routing({path: '/channel_posts', method: 'post'}, {controller: 'channel_posts', action: 'create'})
    end

    it 'Lets posts be viewed' do
      assert_routing '/channel_posts', {controller: 'channel_posts', action: 'index'}
    end
  end

  describe 'Creating posts' do
    before do
      @params = {channel_post: {url: 'http://www.google.com', message: 'What a great site this is.'}}
      @missing_params = {channel_post: {url: 'http://www.google.com'}}
    end

    it 'Returns a 200 response' do
      post :create, @params
      assert_response :success
      assert_template :index

      assert_match /total posts/i, response.body
    end

    it 'Returns a proper malformed request response' do
      post :create, @missing_params
      assert_equal Rack::Utils::SYMBOL_TO_STATUS_CODE[:bad_request], response.response_code
    end

    it 'Creates a ChannelPost record' do
      assert_difference('ChannelPost.count', 1) do
        post :create, @params
      end

      p = ChannelPost.order(created_at: :desc).first
      assert_equal 1, p.redirect_maps.count
    end

    it 'Creates a Twitter post job' do
      assert_enqueued_with(job: TwitterChannelPoster) do
        post :create, @params
      end
    end
  end
end

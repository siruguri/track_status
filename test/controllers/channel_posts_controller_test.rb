require 'test_helper'
require 'webmock/minitest'

class ChannelPostsControllerTest < ActionController::TestCase
  # Tests for Readability controller 
  include ActiveJob::TestHelper
  def setup
    stub_request(:post, "https://#{Rails.application.secrets.twitter_consumer_key}:#{Rails.application.secrets.twitter_consumer_secret}@api.twitter.com/oauth2/token").
      with(:body => "grant_type=client_credentials",
           :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded; charset=UTF-8', 'User-Agent'=>'TwitterRubyGem/5.14.0'}).
      to_return(:status => 200, :body => "{\"token_type\": \"bearer\", \"access_token\":\"myaccesstoken\"}", :headers => {})

    stub_request(:post, "https://api.twitter.com/1.1/statuses/update.json").
      with(:body => /status=/). 

      to_return(:status => 200, :body => "{\"id\": 1}", :headers => {})
  end
  
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
    end
  end
end

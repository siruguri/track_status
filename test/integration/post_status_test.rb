require 'test_helper'
require 'webmock/minitest'

class PostStatusTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  def app
    Rails.application
  end

  def setup
    stub_request(:get, "http://www.binlist.net/json/546616").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => fixture_file('binlist_546616.json'), :headers => {})

    stub_request(:get, "http://www.binlist.net/json/111").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 404, :body => '', :headers => {})
  end
  
  test 'can post binlist request' do
    post '/bindb/add/546616'

    assert_equal last_response.status, 200
    assert_match 'success', last_response.body
  end

  test 'bad number returns 404' do
    post '/bindb/add/111'
    assert last_response.not_found?
  end
end

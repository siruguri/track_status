require 'test_helper'

class PostStatusTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  def app
    Rails.application
  end

  test 'can post status' do
    params={status: {source: 't', description: 't', message: 't'}}
    post '/bindb_add/111', params

    assert_equal last_response.status, 200
    assert_match 'success', last_response.body
  end

end

require 'test_helper'

class PostStatusTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  def app
    Rails.application
  end

  test 'can post binlist request' do
    post '/bindb_add/546616'

    assert_equal last_response.status, 200
    assert_match 'success', last_response.body
  end

  test 'bad number returns 404' do
    post '/bindb_add/111'
    assert last_response.not_found?
  end

end

require 'test_helper'
class AjaxLibraryTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  def setup
  end
    
  describe 'general multiplex' do
    it 'handles errors gracefully' do
      data = Ajax::Library.route_action("actions/trigger/")
      assert_has_error data, 422
      data = Ajax::Library.route_action("actions/trigger/-1")
      assert_has_error data, 422
      data = Ajax::Library.route_action("actions/trigger/a")
      assert_has_error data, 422

      # needs user for some actions
      data = Ajax::Library.route_action("actions/trigger/1")
      assert_has_error data, 422
      data = Ajax::Library.route_action("actions/trigger/3")
      assert_has_error data, 422
    end

    it 'works with valid actions' do
      data = Ajax::Library.route_action("actions/trigger/1", users(:user_2))
      assert_is_success data
    end
  end
  
  private
  def assert_has_error(data, code = 500)
    data[:status] == 'error' and data[:code] == code
  end
  def assert_is_success(data)
    data[:status] == 'success' and data[:code] == '200'
  end
end


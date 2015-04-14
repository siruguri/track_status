require 'test_helper'

class DummyControllerTest < ActionController::TestCase
  describe 'Basic test' do
    it 'shows the test_var variable' do
      get :test_env
      assert_match /test result/, response.body
    end
  end
end

require 'test_helper'
class StatusRecordsControllerTest < ActionController::TestCase
  test 'creation works' do
    assert_difference('Status.count', 1) do
      post :create, params: ({a: 1, b: 2})
    end
  end  
end

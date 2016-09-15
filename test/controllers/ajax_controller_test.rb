require 'test_helper'

class AjaxControllerTest < ActionController::TestCase
  test 'routing' do
    assert_routing ({path: '/ajax_api', method: :post}), {controller: 'ajax', action: 'multiplex'}
  end
  
  test '#multiplex' do
    xhr :post, :multiplex, {payload: "actions/trigger/1"}
    assert_equal 'success', JSON.parse(response.body)['status']
    xhr :post, :multiplex, {payload: "actions/trigger/a"}
    assert_equal 'error', JSON.parse(response.body)['status']
    xhr :post, :multiplex, {payload: "actionsx/trigger/1"}
    assert_equal 'error', JSON.parse(response.body)['status']
    
    post :multiplex, {payload: "actionsx/trigger/1"}    
    assert_equal ({}), JSON.parse(response.body)
    xhr :post, :multiplex, {payload: "reads/trigger/1"}
    assert_equal 200, response.status
  end
end

require 'test_helper'

class StatusesControllerTest < ActionController::TestCase
  test 'routes exist' do
    assert_routing '/statuses', {controller: 'statuses', action: 'index'}
  end

  test 'adds status correctly' do
    good_params = {status: {source: 'mailer', description: 'set options', message: 'success'} }

    assert_difference('Status.count') do
      post :create, good_params
    end

    assert_template nil
    assert_equal 302, response.status
  end
  test 'can show status' do
    s=Status.first
    get :show, {id: s.id}
    
    assert_match s.source, response.body
  end
  
  test 'fails on bad params' do
    bad_params = {}
    post :create, bad_params

    assert_equal 400, response.status
    assert_template nil

    bad_params = {status: {source: 'hello'}}
    post :create, bad_params
    assert_equal 500, response.status
    assert_template nil
  end

end

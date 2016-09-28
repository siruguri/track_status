require 'test_helper'

class StatusesControllerTest < ActionController::TestCase
  test 'routes exist' do
    assert_routing '/statuses', {controller: 'statuses', action: 'index'}
    assert_routing({method: :delete, path: '/statuses'}, {controller: 'statuses', action: 'destroy'})
  end

  test 'adds status correctly' do
    good_params = {status: {source: 'mailer', description: 'set options', message: 'success'} }

    assert_difference('Status.count') do
      post :create, params: good_params
    end

    assert_equal 302, response.status
  end
  test 'can show status' do
    s=Status.first
    get :show, params: {id: s.id}
    
    assert_match s.source, response.body
  end
  
  test 'fails on bad params' do
    bad_params = {}
    post :create, params: bad_params

    assert_equal 400, response.status

    bad_params = {status: {source: 'hello'}}
    post :create, params: bad_params
    assert_equal 500, response.status
  end

  test 'can use limit param' do
    get :index, params: {limit: 1}
    assert_match 'status 1', response.body
    assert (/status 2/.match(response.body).nil?), 'Statuses list had status 2 when it shd not have.'
  end

  test 'can use type param' do
    get :index, params: {type: 'specific'}
    assert_match 'specific', response.body
    assert_no_match 'general', response.body
  end

  describe 'deletion' do
    it 'can delete old statuses with window' do
      # Status exists before deletion
      empty_statuses = Status.where(description: 'sorta old')
      assert_equal 1, empty_statuses.count

      post :destroy, params: {method: :default, day_window: 4}
      empty_statuses = Status.where(description: 'sorta old')
      assert_equal 0, empty_statuses.count
      empty_statuses = Status.where(description: 'too old')
      assert_equal 0, empty_statuses.count
    end
  end
end

require 'test_helper'

class BindbControllerTest < ActionController::TestCase
  test 'routing' do
    assert_routing({method: 'post', path: '/bindb_add/111'}, {controller: 'bindb', action: 'add', bin: '111'})
  end
  
  test 'can create bindb record' do
    bin_number = '546616'
    params = {bin: bin_number}

    post :add, params
    assert_match 'success', response.body    
  end
  
end

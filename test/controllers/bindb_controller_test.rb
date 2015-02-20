require 'test_helper'

class BindbControllerTest < ActionController::TestCase
  def setup
    bin_number = '546616'
    @good_params = {bin: bin_number}
  end
  
  test 'routing' do
    assert_routing({method: 'post', path: '/bindb_add/111'}, {controller: 'bindb', action: 'add', bin: '111'})
  end
  
  test 'can create bindb record' do
    assert_difference('BinRecord.count') do
      post :add, @good_params
    end

    b=BinRecord.last
    assert_equal 'CITIBANK, N.A.', b.bank
    assert_match 'success', response.body
  end

  test 'cannot create dupes' do
    assert_difference('BinRecord.count') do
      post :add, @good_params
    end

    assert_no_difference('BinRecord.count') do
      post :add, @good_params
    end
  end  
end

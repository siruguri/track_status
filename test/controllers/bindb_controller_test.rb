require 'test_helper'

class BindbControllerTest < ActionController::TestCase
  def setup
    bin_number = '546616'
    @good_params = {bin: bin_number}

    stub_request(:get, "http://www.binlist.net/json/546616").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => fixture_file('binlist_546616.json'), :headers => {})
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

  test 'can count bindbs' do
    get :index
    b_last = bin_records(:bin2)
    assert_match '2 records', response.body
    assert_match b_last.number, response.body
    
  end
end

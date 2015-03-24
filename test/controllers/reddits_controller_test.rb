require 'test_helper'
require 'webmock/minitest'

class RedditsControllerTest < ActionController::TestCase
  def setup
    stub_request(:get, 'http://www.reddit.com/user/ssiruguri/').
      with(query: hash_including({count: '25'})).
      to_return(body: open(File.join(Rails.root, 'test', 'fixtures', 'files', 'reddit-page-2.html')).readlines.join(''))

    stub_request(:get, 'http://www.reddit.com/user/ssiruguri/').
      to_return(body: open(File.join(Rails.root, 'test', 'fixtures', 'files', 'reddit-page-1.html')).readlines.join(''))

    stub_request(:get, 'http://www.reddit.com/user/hellobellomello/').
      to_return(body: '', status: 404)

    stub_request(:get, 'http://www.reddit.com/user/errorpage/').
      to_return(body: open(File.join(Rails.root, 'test', 'fixtures', 'files', 'reddit-page-1-error.html')).readlines.join(''))
  end
  
  test 'can populate Reddit user info' do

    # Extraction should happen the first time only.
    assert_difference "RedditRecord.count" do
      get :userinfo, {user: 'ssiruguri'}
    end
    assert_no_difference "RedditRecord.count" do
      get :userinfo, {user: 'ssiruguri'}
    end

    rec = RedditRecord.find_by_username 'ssiruguri'
    assert rec.user_info.keys.include?(:submitted_links), "Something wrong with retrieved record: #{rec.user_info.keys}"

    assert_template :userinfo
    assert_match /Found/, response.body
  end

  test 'fails properly on bad username' do
    get :userinfo, {user: 'hellobellomello'}
    assert_template 'application/blank_page'

    assert_match /No such/, response.body
  end

  test 'fails properly when parsing crashes' do
    get :userinfo, {user: 'errorpage'}
    assert_match /code failed/, response.body
  end
    
end

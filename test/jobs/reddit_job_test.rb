require 'test_helper'

class RedditJobTest < ActiveSupport::TestCase
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

  test 'the reddit record created has keys' do
  #      assert rec.user_info.keys.include?(:submitted_links), "Something wrong with retrieved record: #{rec.user_info.keys}"
  end

  test 'fails properly on bad username' do
    # Perform with get :userinfo, {user: 'hellobellomello'}
    # Assert error mesg with no user
  end

  test 'fails properly when parsing crashes' do
    # Perform with get :userinfo, {user: 'errorpage'}
    # Assert error mesg with parsing error
  end

end

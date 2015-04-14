require 'test_helper'
require 'webmock/minitest'

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

    userinfo = Scrapers::RedditScraper::RedditUserInfo.new
    userinfo[:submitted_links] = {}
    Scrapers::RedditScraper.any_instance.stubs(:user_info).with('ssiruguri').returns(userinfo)

    failed = Scrapers::RedditScraper::RedditUserInfo.new(error: 'extraction really failed')
    Scrapers::RedditScraper.any_instance.stubs(:user_info).with('failure').returns(failed)

    hbm_fail = Scrapers::RedditScraper::RedditUserInfo.new(error: 'no such user')
    Scrapers::RedditScraper.any_instance.stubs(:user_info).with('hellobellomello').returns(hbm_fail)
  end

  test 'the reddit record created has keys' do
    RedditJob.new(reddit_records(:valid_user)).perform_now
    obj = reddit_records(:valid_user)
    
    assert obj.user_info.keys.include?(:submitted_links), "Something wrong with retrieved record: #{obj.user_info.keys}"
  end

  test 'fails properly on bad username' do
    # Perform with get :userinfo, {user: 'hellobellomello'}
    RedditJob.new(reddit_records(:nil_user)).perform_now
    assert reddit_records(:nil_user).user_info.error?
  end

  test 'fails properly when parsing crashes' do
    RedditJob.new(reddit_records(:failed_user)).perform_now
    assert_match /extraction.*failed/i, reddit_records(:failed_user).user_info.error
  end

  def teardown
    Scrapers::RedditScraper.any_instance.unstub(:user_info)
  end
end

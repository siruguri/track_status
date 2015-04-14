require 'test_helper'
require 'webmock/minitest'

class RedditsControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper
  self.use_transactional_fixtures = true
  
  def setup
    # The reddit jobs test assumes there are records in the database, but the controller tests need
    # to assume there aren't.

    RedditRecord.all.map &:delete
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
    assert_match /started/, response.body

    assert_no_difference "RedditRecord.count" do
      get :userinfo, {user: 'ssiruguri'}
    end
    assert_template :userinfo
    assert_match /Found/, response.body
    
    rec = RedditRecord.find_by_username 'ssiruguri'
    assert rec.extraction_in_progress
    perform_enqueued_jobs { RedditJob.perform_now(rec) }
    rec = RedditRecord.find_by_username 'ssiruguri'
    
    assert_not rec.extraction_in_progress
  end

  test 'jobs are created' do
    assert_enqueued_with(job: RedditJob, queue: 'scrapers') do
      get :userinfo, {user: 'ssiruguri'}
    end
  end
end

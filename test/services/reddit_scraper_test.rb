require 'test_helper'

class RedditScraperTest < ActiveSupport::TestCase
  def setup 
    @test_obj = RedditScraper.new
    stub_request(:get, 'http://www.reddit.com/user/ssiruguri/').
      with(query: hash_including({count: '25'})).
      to_return(body: open(File.join(Rails.root, 'test', 'fixtures', 'files', 'reddit-page-2.html')).readlines.join(''))

    stub_request(:get, 'http://www.reddit.com/user/ssiruguri/').
      to_return(body: open(File.join(Rails.root, 'test', 'fixtures', 'files', 'reddit-page-1.html')).readlines.join(''))

    stub_request(:get, 'http://www.reddit.com/user/hellobellomello/').
      to_return(body: '', status: 404)
  end
  
  test 'valid username works' do
    payload = @test_obj.user_info(:ssiruguri)
    
    assert (payload[:submitted_links] == 41), "Failed to find 41 submitted links, found #{payload[:submitted_links]}"

    assert_equal 5, payload[:subreddit_counts]['nonprofit.']
  end
  
  test 'invalid username does not work' do
    assert_equal nil, @test_obj.user_info(:hellobellomello)
  end
end


require 'test_helper'

class TwitterRedirectFetchJobTest < ActiveSupport::TestCase
  def setup
    set_net_stubs
  end
  
  test 'exceptions raised cause flag to be set' do
    assert_equal nil, web_articles(:web_article_1).fetch_failed
    ReadabilityParserWrapper.any_instance.stubs(:parse).raises Errno::ECONNREFUSED
    TwitterRedirectFetchJob.perform_now web_articles(:web_article_1)
    refute web_articles(:web_article_1).fetch_failed
  end

  test 't.co redirects work' do
    TwitterRedirectFetchJob.perform_now web_articles(:t_co_1)
  end
end

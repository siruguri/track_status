require 'test_helper'

class TwitterRedirectFetchJobTest < ActiveSupport::TestCase
  test 'exceptions raised cause flag to be set' do
    assert_equal nil, web_articles(:web_article_1).fetch_failed
    ReadabilityParserWrapper.any_instance.stubs(:parse).raises Errno::ECONNREFUSED
    TwitterRedirectFetchJob.perform_now web_articles(:web_article_1)
    refute web_articles(:web_article_1).fetch_failed
  end
end

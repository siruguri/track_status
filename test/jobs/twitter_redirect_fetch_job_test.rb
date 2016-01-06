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

  test 'readability failure is handled' do
    ReadabilityParserWrapper.any_instance.stubs(:parse).returns(ReadabilityParserWrapper::ReadabilityBody.new(content: {failure_message: 'failed'}, url: 'url'))

    TwitterRedirectFetchJob.perform_now web_articles(:wa_uncrawled)
    assert_equal 'failed', web_articles(:wa_uncrawled).body
  end
end

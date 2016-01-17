require 'test_helper'
require 'webmock/minitest'

class EmailControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper

  def mandrill_request
    fixture_file('mandrill_request.txt')
  end

  def setup
    set_net_stubs
  end

  test 'has processing route' do
    assert_routing({method: 'post', path: '/process_email'}, {controller: 'email', action: 'transform'})
  end

  test 'reanalysis works' do
    assert_enqueued_with(job: ReanalyzeEmailsJob) do
      post :reanalyze
    end
  end
  
  test 'responds to mandrill request' do
    init_re_count = ReceivedEmail.count
    init_wa_count = WebArticle.count
    assert_enqueued_with(job: ActionMailer::DeliveryJob) do
      post :transform, {mandrill_events: mandrill_request}
    end

    assert_equal init_wa_count + 1, WebArticle.count
    assert_equal init_re_count + 1, ReceivedEmail.count
    assert_equal Array, ReceivedEmail.last.payload.class
    
    assert_match 'success', response.body
  end

  test 'responds to wildcard requests' do
    init_re_count = ReceivedEmail.count
    init_wa_count = WebArticle.count
    assert_enqueued_with(job: ActionMailer::DeliveryJob) do
      post :transform, {mandrill_events: mandrill_request, wildcard: 'true'}
    end
    assert_equal init_wa_count, WebArticle.count

    assert_equal 'GeneralMailer', enqueued_jobs.last[:args][0]
    assert_equal 'wildcard', enqueued_jobs.last[:args][3]['type']
  end
  
end

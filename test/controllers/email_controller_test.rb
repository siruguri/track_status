require 'test_helper'
require 'webmock/minitest'

class EmailControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper

  def mandrill_request
    fixture_file('mandrill_request.txt')
  end
  def sendgrid_request
    fixture_file('sendgrid_request.txt')
  end
  def sendgrid_request_html
    fixture_file('sendgrid_request_html.txt')
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

  test 'responds to dev_body debugging' do
    assert_enqueued_with(job: ActionMailer::DeliveryJob) do
      post :transform, params: {dev_body: 'hello'}
    end
  end
  
  test 'responds to sendgrid and mandrill requests' do
    assert_creation({mandrill_events: mandrill_request}) 
    assert_creation(JSON.parse(sendgrid_request)) do |fields|
      assert_match 'sendgrid', fields['subject']
    end
    
    assert_creation(JSON.parse(sendgrid_request_html))
  end

  test 'handles bad input' do
    post :transform, bad_input_sample
  end
  
  test 'responds to sparkpost' do
    init_wa_count = WebArticle.count
    assert_enqueued_with(job: ActionMailer::DeliveryJob) do
      post :transform, sparkpost_json_sample
    end
    assert_equal init_wa_count + 1, WebArticle.count
    assert_equal 'sparkpost', ReceivedEmail.last.source
  end
  
  test 'responds to wildcard requests' do
    init_re_count = ReceivedEmail.count
    assert_enqueued_with(job: ActionMailer::DeliveryJob) do
      post :transform, params: {mandrill_events: mandrill_request, wildcard: 'true'}
    end
    assert_equal 'GeneralMailer', enqueued_jobs.last[:args][0]
  end
  
  private
  def assert_creation(req_hash)
    init_re_count = ReceivedEmail.count
    init_wa_count = WebArticle.count
    assert_enqueued_with(job: ActionMailer::DeliveryJob) do
      post :transform, params: req_hash
    end

    assert_equal init_re_count + 1, ReceivedEmail.count
    assert_equal Array, ReceivedEmail.last.payload.class
    assert_match 'success', response.body

    if block_given?
      yield enqueued_jobs.last[:args][3]['fields']
    end
  end

  def sparkpost_json_sample
    {params: {'_json' => [{'msys' => {'relay_message' => {'content' => {'text' => 'this is sparkpost text and http://www.google.com'}}}}]}}
  end
  
  def bad_input_sample
    {params: {'_json' => {'msys' => 1}}}
  end
end

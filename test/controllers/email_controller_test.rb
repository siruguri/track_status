require 'test_helper'

class EmailControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper

  test 'has processing route' do
    assert_routing({method: 'post', path: '/process_email'}, {controller: 'email', action: 'transform'})
  end
  
  test 'responds to mandrill request' do
    init_count = ReceivedEmail.count
    assert_enqueued_with(job: ActionMailer::DeliveryJob) do
      post :transform, {mandrill_events: [{'event':'inbound'}].to_json}
    end

    assert_match 'success', response.body
  end
end

require 'test_helper'
class GeneralMailerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  
  test 'test it' do
    assert_difference('ActionMailer::Base.deliveries.size', 1) do
      GeneralMailer.notification_email(payload: crafted_payload).deliver_now
    end

    lastmail = ActionMailer::Base.deliveries[0]
    binding.pry if (Regexp.new('JSON is: {&quot;source') =~ lastmail.body.to_s).nil?
    assert(Regexp.new('JSON is: {&quot;source') =~ lastmail.body.to_s)
  end

  private
  def crafted_payload
    EmailController::MailServicePayload.new(
      'sparkpost',
      {'_json' => [{'msys' => {'relay_message' => {'content' => {'text' => 'this is sparkpost text'}}}}]}
    )
  end
end

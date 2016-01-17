require 'test_helper'
class GeneralMailerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  
  test 'test it' do
    GeneralMailer.notification_email(payload: 'thebody', 'type' => 'wildcard').deliver_now

    assert_match /wildcard$/, ActionMailer::Base.deliveries.last.subject
  end
end


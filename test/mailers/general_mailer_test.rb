require 'test_helper'
class GeneralMailerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  
  test 'test it' do
    assert_difference('ActionMailer::Base.deliveries.size', 1) do
      GeneralMailer.notification_email(payload: 'thebody').deliver_now
    end
  end
end


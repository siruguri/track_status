require 'test_helper'

class TwitterClientWrapperTest < ActiveSupport::TestCase
  def setup
    set_net_stubs
    @c = TwitterClientWrapper.new
  end

  test 'rate limiting works' do
    now = Time.now
    handle = twitter_profiles :twitter_profile_1
    
    (1..13).each do |t|
      @c.rate_limited do
        fetch_profile! handle
      end
    end

    # That should have set off the rate limiting exactly once.
    assert_equal 1, TwitterRequestRecord.where('created_at >= ? and ran_limit = ?', now, true).count
  end
end


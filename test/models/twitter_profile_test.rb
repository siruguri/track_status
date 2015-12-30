require 'test_helper'

class TwitterProfileTest < ActiveSupport::TestCase
  test 'tweets_count default is 0' do
    t = TwitterProfile.new(handle: 'handle_x', twitter_id: 12345)
    t.save
    assert_equal 0, t.tweets_count
  end
end

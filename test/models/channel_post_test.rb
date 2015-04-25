require 'test_helper'

class ChannelPostTest < ActiveSupport::TestCase
  test 'New records have 0 post count' do
    c = ChannelPost.new(url: 'http://www.google.com', message: 'mesg'); c.save
    assert_equal 0, c.total_post_count
  end
end

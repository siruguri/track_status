require 'test_helper'

class TwitterClientWrapperTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  
  def setup
    set_net_stubs
    @c = TwitterClientWrapper.new
    @handle = twitter_profiles :twitter_profile_1
  end

  test 'rate limiting works' do
    now = Time.now
    
    (1..13).each do |t|
      h = @handle
      @c.rate_limited do
        fetch_profile! h
      end
    end

    # That should have set off the rate limiting exactly once.
    assert_equal 1, TwitterRequestRecord.where('created_at >= ? and ran_limit = ?', now, true).count
  end

  test 'profile fetching works' do
    h = @handle
    @c.rate_limited do
      fetch_profile! h
    end

    assert_equal "Fri Jun 12 19:50:18 +0000 2015", twitter_profiles(:twitter_profile_1).last_tweet[:created_at]
    assert_equal 4242, twitter_profiles(:twitter_profile_1).tweets_count
  end
  
  test 'plain tweets fetching works' do
    wa_ct = WebArticle.count
    assert_difference('TweetPacket.count', 1) do
      h = @handle
      @c.rate_limited do
        fetch_tweets! h
       end
    end

    assert_equal 2, enqueued_jobs.size
    assert_equal 2 + wa_ct, WebArticle.count
    assert_equal 'twitter', WebArticle.last.source

    assert_equal TweetPacket.last.id, WebArticle.last.tweet_packet_id
    assert_equal 2, TweetPacket.last.tweets_list.size
  end

  test 'cursored tweets fetching works' do
    assert_difference('TweetPacket.count', 1) do
      h = @handle
      pks = tweet_packets(:tweet_packet_1)
      
      @c.rate_limited do
        fetch_tweets! h, pks
       end
    end

    tl = TweetPacket.last
    assert_equal 3, tl.tweets_list.size
    assert_equal @handle.handle, tl.handle
  end    
end


# Create dummy tweets for the first day a non tweeting profile joined, that is not protected
ts = TwitterProfile.joins('left outer join tweets on tweets.twitter_id = twitter_profiles.twitter_id').where('tweets.id is null and twitter_profiles.protected != \'t\'')

ts.each do |t|
  if t.member_since.present?
    puts "Dummy tweet for #{t.handle}"
    tw = Tweet.new twitter_id: t.twitter_id, tweet_id: SecureRandom.hex(16).hex.to_s[0..16].to_i, mesg: 'dummy tweet track_status',
                   tweet_details: ({}), tweeted_at: t.member_since + 1.day, is_retweeted: false, processed: true
    tw.save!
  else
    puts "No tweets for #{t.handle}"
  end    
end


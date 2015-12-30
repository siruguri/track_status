TwitterProfile.all.each do |p|
  if p.tweets_count.nil?
    p.tweets_count = 0
    puts "Fixing for profile #{p.twitter_id || p.handle}"
    p.save
  end
end

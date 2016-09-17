token_me = User.find_by_email('siruguri@gmail.com').latest_token_hash
token_nb = User.find_by_email('novelbeginnings@offtherailsapps.com').latest_token_hash

c_me = TwitterClientWrapper.new token: token_me
c_nb = TwitterClientWrapper.new token: token_nb

me_thread = Thread.new do
  ps_me = TwitterProfile.where('member_since is null').order(created_at: :desc).limit 50
  ps_me.each do |p|
    puts "For me: fetching #{p.handle}"
    c_me.rate_limited { fetch_profile!(p) } 
  end
end

nb_thread = Thread.new do
  ps_nb = TwitterProfile.where('member_since is null').order(created_at: :desc).offset(51).limit 50
  ps_nb.each do |p|
    puts "For nb: fetching #{p.handle}"
    c_nb.rate_limited { fetch_profile!(p) }
  end
end

me_thread.join
nb_thread.join

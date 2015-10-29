def app_token_headers
  {'Accept' => 'application/json', 'Authorization' => /cjCezt7cqCpk2c9XgtufSw9zh.*abcdefgh/}
end

def single_token_headers
  {'Accept' => 'application/json', 'Authorization' => /cjCezt7cqCpk2c9XgtufSw9zh.*#{Rails.application.secrets.twitter_single_app_access_token}/}
end

def valid_twitter_plaintweets_response
  fixture_file('twitter_plaintweets_array.json')
end
def valid_twitter_oldertweets_response
  fixture_file('twitter_oldertweets_array.json')
end

def valid_twitter_profile_response
  {
    "contributors_enabled": false,
   "created_at": "Sat Dec 14 04:35:55 +0000 2013",
   "description": "Developer and Platform Relations @Twitter. We are developer advocates. We can't answer all your questions, but we listen to all of them!",
   "favourites_count": 757,
   "followers_count": 143916,
   "following": false,
   "friends_count": 1484,
   "geo_enabled": true,
   "id": 2244994945,
   "id_str": "2244994945",
   "location": "Oakland",
   "name": "TwitterDev",
   "screen_name": "TwitterDev",
   "statuses_count": 1279,
   "time_zone": "Pacific Time (US & Canada)",
   "url": "https://t.co/66w26cua1O",
  }.to_json
end

def invalid_twitter_response
  {
    'errors': [    {
                     "code": 34,
                    "message": "Sorry, that page does not exist."
                   }]}.to_json
end

def set_net_stubs
  stub_request(:get, "https://www.readability.com/api/content/v1/parser?format=json&token=testreadabilityapikey&url=https://medium.com/bolt-blog/who-invests-in-hardware-startups-d1612895a31a").
    with(:headers => {'Accept'=>'*/*'}).
    to_return(:status => 200, :body => fixture_file('readability-aldaily-file-1.html'), :headers => {})


  stub_request(:get, "https://api.twitter.com/1.1/users/show.json?screen_name=twitter_handle").
    to_return(status: 200, body: valid_twitter_profile_response)
  
  stub_request(:get, "https://api.twitter.com/1.1/users/show.json?screen_name=nota_twitter_handle").
    to_return(status: 404, body: invalid_twitter_response)
  
  stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&exclude_replies=true&include_rts=true&screen_name=twitter_handle&trim_user=1").
    with(headers: app_token_headers).
    to_return(status: 200, body: valid_twitter_plaintweets_response)

  stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&exclude_replies=true&include_rts=true&max_id=1212&screen_name=twitter_handle&trim_user=1").
    with(headers: app_token_headers).    
    to_return(status: 200, body: valid_twitter_oldertweets_response)

  stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&exclude_replies=true&include_rts=true&screen_name=twitter_handle&trim_user=1").
    with(headers: single_token_headers).
    to_return(status: 200, body: valid_twitter_plaintweets_response)

  stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&exclude_replies=true&include_rts=true&max_id=1212&screen_name=twitter_handle&trim_user=1").
    with(headers: single_token_headers).    
    to_return(status: 200, body: valid_twitter_oldertweets_response)  
end

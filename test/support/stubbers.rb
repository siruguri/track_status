def app_token_headers
  {'Accept' => 'application/json', 'Authorization' => /cjCezt7cqCpk2c9XgtufSw9zh.*abcdefgh/}
end

def single_token_headers
  {'Accept' => 'application/json', 'Authorization' => /cjCezt7cqCpk2c9XgtufSw9zh.*#{Rails.application.secrets.twitter_single_app_access_token}/}
end

def valid_twitter_response(type)
  fixture_file("twitter_#{type}_array.json")
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
    to_return(:status => 200, :body => fixture_file('readability-aldaily-file-1.html'), :headers => {'Content-Type' => 'UTF-8'})


  stub_request(:get, "https://api.twitter.com/1.1/users/show.json?screen_name=twitter_handle").
    to_return(status: 200, body: valid_twitter_response(:profile))
  
  stub_request(:get, "https://api.twitter.com/1.1/users/show.json?screen_name=nota_twitter_handle").
    to_return(status: 404, body: invalid_twitter_response)
  
             
  stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&exclude_replies=true&include_rts=true&screen_name=twitter_handle&trim_user=1").
    with(headers: app_token_headers).
    to_return(status: 200, body: valid_twitter_response(:plaintweets))

  stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&exclude_replies=true&include_rts=true&max_id=oldest_tweet_id&screen_name=twitter_handle&trim_user=1").
    with(headers: app_token_headers).    
    to_return(status: 200, body: valid_twitter_response(:oldertweets))

  # "https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&exclude_replies=true&include_rts=true&max_id=1212&screen_name=twitter_handle&trim_user=1")
  stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&exclude_replies=true&include_rts=true&screen_name=twitter_handle&trim_user=1").
    with(headers: single_token_headers).
    to_return(status: 200, body: valid_twitter_response(:plaintweets))

  stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&exclude_replies=true&include_rts=true&max_id=oldest_tweet_id&screen_name=twitter_handle&trim_user=1").
    with(headers: single_token_headers).    
    to_return(status: 200, body: valid_twitter_response(:oldertweets))

  stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&exclude_replies=true&include_rts=true&screen_name=twitter_handle&since_id=latest_tweet_id&trim_user=1").
    with(headers: single_token_headers).
    to_return(status: 200, body: valid_twitter_response(:newertweets))
  
  # Followers
  stub_request(:get, "https://api.twitter.com/1.1/followers/ids.json?screen_name=twitter_handle").
    with(headers: single_token_headers).    
    to_return(status: 200, body: valid_twitter_response(:followers))

  stub_request(:get, "https://t.co/MjJ8xAnT").
    with(:headers => {'Accept'=>'*/*',  'Host'=>'t.co'}).
    to_return(:status => 200, :body => "hello")

  stub_request(:get, /https?:..t\.co/).
    with(:headers => {'Accept'=>'*/*',  'Host'=>'t.co'}).
    to_return(:status => 301, :body => "", :headers => {'location' => 'http://redirected.to/1'})

  stub_request(:get, /.*token=testreadabilityapikey.*url=.*dev.witter/).
    with(:headers => {'Accept'=>'*/*'}).
    to_return(:status => 200, body: fixture_file('readability-aldaily-file-1.html'), headers: {'Content-Type' => 'UTF-8'})
  stub_request(:get, /.*token=testreadabilityapikey.*url=.*redirected\.to/).
    with(:headers => {'Accept'=>'*/*'}).
    to_return(:status => 200, body: fixture_file('readability-aldaily-file-1.html'), headers: {'Content-Type' => 'UTF-8'})
end

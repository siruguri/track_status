def set_net_stubs
  stub_request(:get, "https://www.readability.com/api/content/v1/parser?format=json&token=testreadabilityapikey&url=https://medium.com/bolt-blog/who-invests-in-hardware-startups-d1612895a31a").
    with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'www.readability.com', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => fixture_file('readability-aldaily-file-1.html'), :headers => {})
end

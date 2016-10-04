def set_net_stubs
  # Readability
  stub_request(:get, "https://www.readability.com/api/content/v1/parser?format=json&token=testreadabilityapikey&url=https://medium.com/bolt-blog/who-invests-in-hardware-startups-d1612895a31a").
    with(:headers => {'Accept'=>'*/*'}).
    to_return(:status => 200, body: fixture_file('readability-aldaily-file-1.html'), headers: {'Content-Type' => 'UTF-8'})

  stub_request(:get, /.*token=testreadabilityapikey.*url=.*dev.witter/).
    with(:headers => {'Accept'=>'*/*'}).
    to_return(:status => 200, body: fixture_file('readability-aldaily-file-1.html'), headers: {'Content-Type' => 'UTF-8'})

  stub_request(:get, /.*token=testreadabilityapikey.*url=.*redirected\.to/).
    with(:headers => {'Accept'=>'*/*'}).
    to_return(:status => 200, body: fixture_file('readability-aldaily-file-1.html'), headers: {'Content-Type' => 'UTF-8'})

  stub_request(:get, "https://www.readability.com/api/content/v1/parser?format=json&token=testreadabilityapikey&url=http://www.reanalysis_1.com/uri1").
    with(:headers => {'Accept'=>'*/*'}).
    to_return(:status => 200, :body => fixture_file('readability-aldaily-file-1.html'), :headers => {'Content-Type' => 'UTF-8'})

  # Aldaily/readability
  stub_request(:get, /.readability.com.*parser.*economist/).
    to_return(status: 200, body: fixture_file('readability-aldaily-file-2.html'),
              headers: {'Content-Type' => 'application/json; charset=utf-8'})
  stub_request(:get, /.readability.com.*parser.*spectator/).
    to_return(status: 200, body: fixture_file('readability-aldaily-file-1.html'),
              headers: {'Content-Type' => 'application/json; charset=utf-8'})
  stub_request(:get, /.readability.com.*parser.*aeon/).
    to_return(status: 200, body: fixture_file('readability-aldaily-file-3.html'),
              headers: {'Content-Type' => 'application/json; charset=utf-8'})

  stub_request(:get, 'http://www.aldaily.com/').
    to_return(body: fixture_file('aldaily-page.html'))
end

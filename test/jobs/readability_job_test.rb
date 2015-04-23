require 'test_helper'
require 'webmock/minitest'

class ReadabilityJobTest < ActiveSupport::TestCase
  def setup
    stub_request(:get, 'http://www.aldaily.com/').
      to_return(body: fixture_file('aldaily-page.html'))

    stub_request(:get, "https://readability.com/api/content/v1/parser?format=json&token=476680056d0053eed25ebd46d9b40a72975cdb1b&url=http://www.nytimes.com/2015/04/12/education/edlife/12edl-12mfa.html").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'ReadabilityParser Ruby Gem 0.0.5'}).
      to_return(status: 200, body: fixture_file('readability-aldaily-file-1.html'),
                headers: {'Content-Type' => 'application/json; charset=utf-8'})

    stub_request(:get, "https://readability.com/api/content/v1/parser?format=json&token=476680056d0053eed25ebd46d9b40a72975cdb1b&url=http://www.the-tls.co.uk/tls/public/article1541210.ece").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'ReadabilityParser Ruby Gem 0.0.5'}).
      to_return(status: 200, body: fixture_file('readability-aldaily-file-2.html'),
                headers: {'Content-Type' => 'application/json; charset=utf-8'})

      stub_request(:get, "https://readability.com/api/content/v1/parser?format=json&token=476680056d0053eed25ebd46d9b40a72975cdb1b&url=https://www.commentarymagazine.com/article/the-moral-urgency-of-anna-karenina/").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'ReadabilityParser Ruby Gem 0.0.5'}).
      to_return(status: 200, body: fixture_file('readability-aldaily-file-3.html'),
                headers: {'Content-Type' => 'application/json; charset=utf-8'})
end

  test 'Running the job gets articles' do
    assert_difference('WebArticle.count', 3) do
      ReadabilityJob.perform_now(:aldaily)
    end

    w = WebArticle.last
    assert_equal 'https://www.commentarymagazine.com/article/the-moral-urgency-of-anna-karenina/',
                 w.original_url
  end
end

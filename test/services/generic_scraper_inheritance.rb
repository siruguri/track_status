require 'test_helper'

class GenericScraperInheritance < ActiveSupport::TestCase
  class NewScraper < Scrapers::GenericScraper
  end

  def setup
    stub_request(:get, 'http://www.google.com').to_return(
      status: 200, body: fixture_file('google-response.html'))
      
    @new_scraper = NewScraper.new('http://www.google.com')
  end

  test 'Basic inheritance works' do
    assert_equal 'Google', @new_scraper.create_payload[:title]
  end

  test 'socket error correctly raised' do
    WebMock.disable!
    @bad_scraper = NewScraper.new('http://notauri')
    assert_raises(SocketError) do
      @bad_scraper.create_payload
    end
    WebMock.disable_net_connect!(allow_localhost: true)
  end
end

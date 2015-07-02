require 'test_helper'

class RtMovieScraperTest < ActiveSupport::TestCase
  def setup
    stub_request(:get, 'http://www.rottentomatoes.com/m/moviename').to_return(
      status: 200, body: fixture_file('rt-response.html'))
  end

  test 'RT scraper works' do
    r=Scrapers::RtMovieScraper.new('http://www.rottentomatoes.com/m/moviename')
    r.create_payload; r.post_process_payload
    assert_equal 2, r.payload[:ratings].size
  end
end

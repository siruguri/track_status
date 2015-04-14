require 'test_helper'

class ReadabilityControllerTest < ActionController::TestCase
  # Tests for Readability controller 

  describe 'Routing' do
    it 'Allows a scrape to be requested' do
      assert_routing '/readability/run_scrape', {controller: 'readability', action: 'run_scrape'}
    end
  end
  
  describe 'Readability job queue' do
    before do
      Sidekiq::Queue.new(:scrapers).each do |j|
        j.delete
      end
    end
    
    it 'runs a job once per day' do 
      get :run_scrape, site: 'aldaily'

      assert_match /job created/i, response.body
      get :run_scrape, site: 'aldaily'

      assert_match /previous/i, response.body
    end
  end
end

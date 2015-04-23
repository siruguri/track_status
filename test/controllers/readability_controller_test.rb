require 'test_helper'
require 'webmock/minitest'

class ReadabilityControllerTest < ActionController::TestCase
  # Tests for Readability controller 
  include ActiveJob::TestHelper
  
  describe 'Routing' do
    it 'Allows a scrape to be requested' do
      assert_routing '/readability/run_scrape', {controller: 'readability', action: 'run_scrape'}
    end

    it 'Lists articles' do
      assert_routing '/readability/list', {controller: 'readability', action: 'list_articles'}
    end
  end
  
  describe 'Readability job queue' do
    it 'runs a job succesfully when it is not Sunday' do
      t = Date.parse('2015-04-11')
      Time.stubs(:now).returns t.to_time + 1.minute

      assert_difference('JobRecord.count', 1) do
        get :run_scrape, site: 'aldaily'
      end
      
      assert_match /job created/i, response.body

      Time.unstub :now
    end

    it 'does not run jobs on Sundays' do
      t = Date.parse('2015-04-12')
      Time.stubs(:now).returns t.to_time + 1.minute
      assert_no_enqueued_jobs do
        get :run_scrape, site: 'aldaily'
      end

      assert_match /no jobs/i, response.body
      Time.unstub :now
    end
  end

  describe 'readability article browse' do
    it 'shows the most recently created article' do
      all_articles = WebArticle.all.order(created_at: :desc)
      
      get :list_articles, site: 'aldaily'
      assert_template :list
      assert_match /article 1 content/, response.body

      assert_select('a', 2) do |link|
        if link.attribute('id').value == 'next'
          assert_match /\?start=1/, link.attribute('href').value
        else
          assert_equal 'http://www.origsource.com/article_1', link.attribute('href').value
        end
      end
    end
  end
end

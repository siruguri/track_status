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

    it 'requires 24 hours to pass between jobs' do
      t = DateTime.parse('2015-04-11 01:00:00')
      Time.stubs(:now).returns t.to_time + 1.minute
      assert_difference('JobRecord.count', 1) do
        get :run_scrape, site: 'aldaily'
      end

      Time.stubs(:now).returns t.to_time + 2.hours
      assert_no_difference('JobRecord.count', 1) do
        get :run_scrape, site: 'aldaily'
      end

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
      assert_match /Combines all/, response.body

      assert_select('a', 2) do |link|
        if link.attribute('id').value == 'next'
          assert_match /\?start=1/, link.attribute('href').value
        else
          assert_equal 'http://www.origsource.com/article_3', link.attribute('href').value
        end
      end
    end

    it 'works when there is no original URL' do
      get :list_articles, site: 'aldaily', start: 2
      assert_template :list
    end
  end

  describe 'Article bigram API' do
    it 'fails correctly' do
      get :tag_words, id: 'cannot be id'

      assert_match /json/, response.headers['Content-Type']
      assert_equal "[]", response.body
    end

    it 'gets words correctly' do
      get :tag_words, id: web_articles(:web_article_3).id
      exp_bigrams_json = "[{\"id\":0,\"name\":\"initial value\"},{\"id\":1,\"name\":\"named method\"},{\"id\":2,\"name\":\"value memo\"},{\"id\":3,\"name\":\"collection will\"},{\"id\":4,\"name\":\"accumulator value\"}]"

      assert_equal exp_bigrams_json, response.body
    end
  end
end

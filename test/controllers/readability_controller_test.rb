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

      # 3 links - next, prev and orig
      assert_select('a', 3) do |link|
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
      assert_select('a', 3) do |link|
        if link.attribute('id').value == 'prev'
          assert_match /\?start=0/, link.attribute('href').value
        end
      end      
    end
  end

  describe 'Article bigram API' do
    it 'fails correctly' do
      get :tag_words, id: 'cannot be id'

      assert_match /json/, response.headers['Content-Type']
      assert_equal "[]", response.body
    end
  end
  
  describe'Correct functioning' do
    it 'uses raw score correctly' do
      get :tag_words, id: web_articles(:web_article_3).id, sort_by: 'raw'
      exp_bigrams_json = "[{\"id\":0,\"name\":\"initial value\"},{\"id\":1,\"name\":\"named method\"},{\"id\":2,\"name\":\"value memo\"},{\"id\":3,\"name\":\"collection will\"},{\"id\":4,\"name\":\"accumulator value\"}]"

      assert_equal exp_bigrams_json, response.body
    end

    it 'uses unigram boosting correctly' do
      get :tag_words, id: web_articles(:web_article_3).id, sort_by: 'unigram_boosted'
      exp_bigrams_json = "[{\"id\":0,\"name\":\"value memo\"},{\"id\":1,\"name\":\"initial value\"},{\"id\":2,\"name\":\"accumulator value\"},{\"id\":3,\"name\":\"return value\"},{\"id\":4,\"name\":\"final value\"}]"     

      assert_equal exp_bigrams_json, response.body
    end
  end

  describe 'Tagging' do
    before do
      @article = web_articles(:web_article_1)
      @avlb_tag = article_tags(:tag_1)      
    end
    it 'tags correctly with new tags' do
      init_tag_count = ArticleTag.count
      assert_difference('ArticleTagging.count', 2) do
        post :tag_article, {article_id_tag: @article.id, token_list: @avlb_tag.label+',will be a new label'}
      end
      assert_redirected_to readability_list_path
      
      assert_equal init_tag_count + 1, ArticleTag.count
    end

    it 'tags correctly with a new tag' do
      init_tag_count = ArticleTag.count
      assert_difference('ArticleTagging.count', 1) do
        post :tag_article, {article_id_tag: @article.id, token_list: article_tags(:article_tag_existing).label+
                                                         ',will be a new label'}
      end

      assert_equal init_tag_count + 1, ArticleTag.count
    end
  end
end

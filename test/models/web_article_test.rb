require 'test_helper'

class WebArticleTest < ActiveSupport::TestCase
  test 'Validations work' do
    assert_not WebArticle.new(original_url: 'not a uri').valid?
  end

  test 'bigrams works' do
    exp_bigrams_list = [{:id=>0, :name=>"value for"}, {:id=>1, :name=>"If you"}, {:id=>2, :name=>"of memo"}, {:id=>3, :name=>"element in"}, {:id=>4, :name=>"a block"}]
    assert_equal exp_bigrams_list, web_articles(:web_article_3).top_bigrams
  end
end

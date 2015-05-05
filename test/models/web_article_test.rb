require 'test_helper'

class WebArticleTest < ActiveSupport::TestCase
  test 'Validations work' do
    assert_not WebArticle.new(original_url: 'not a uri').valid?
  end

  test 'bigrams works' do
    exp_bigrams_list = [{:id=>0, :name=>"initial value"}, {:id=>1, :name=>"named method"}, {:id=>2, :name=>"value memo"}, {:id=>3, :name=>"collection will"}, {:id=>4, :name=>"accumulator value"}]

    assert_equal exp_bigrams_list, web_articles(:web_article_3).top_grams('raw')
  end
end

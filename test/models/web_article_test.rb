require 'test_helper'

class WebArticleTest < ActiveSupport::TestCase
  test 'Validations work' do
    assert_not WebArticle.new(original_url: 'not a uri').valid?
  end

  test 'bigrams works' do
    exp_bigrams_list = [{:id=>0, :name=>"initial value"}, {:id=>1, :name=>"named method"}, {:id=>2, :name=>"value memo"}, {:id=>3, :name=>"collection will"}, {:id=>4, :name=>"accumulator value"}]

    refute_equal (web_articles(:web_article_3).top_grams('raw') - exp_bigrams_list).size,
                 web_articles(:web_article_3).top_grams('raw').size
  end

  test 'nil body in web article works for bigrams' do
    assert_equal [], web_articles(:nil_body).top_grams('raw')
  end
end

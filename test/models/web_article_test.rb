require 'test_helper'

class WebArticleTest < ActiveSupport::TestCase
  test 'Validations work' do
    assert_not WebArticle.new(original_url: 'not a uri').valid?
  end
end

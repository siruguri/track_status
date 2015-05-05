require 'test_helper'

class ReadabilityArticlesTagsTest < Capybara::Rails::TestCase
  include Rack::Test::Methods

  def setup
    Capybara.default_driver = :selenium
  end
  
  test 'can see tags list' do
    visit '/readability/list'
    page.find('#token-input-tags-list').set('a')

    assert page.has_css?('.token-input-dropdown ul li', count: 5)
    assert_equal 'value memo', page.find('.token-input-dropdown ul li:first-child').text
  end
end

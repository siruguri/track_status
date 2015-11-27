require 'test_helper'

class ReadabilityArticlesTagsTest < Capybara::Rails::TestCase
  include Rack::Test::Methods

  def setup
    Capybara.default_driver = :poltergeist

  end
  
  test 'can see tags list' do
    visit '/readability/list'
    page.find('#token-input-tags-list').native.send_keys('a')
    page.find('#token-input-tags-list')
    assert page.has_css?('.token-input-dropdown ul li', count: 5)

    suggested_value = page.find('.token-input-dropdown ul li:first-child')
    assert_equal 'value memo', suggested_value.text
  end

  test 'can tag article' do
    visit '/readability/list'
    
    c = page.find('#token-input-tags-list')
    c.native.send_keys 'abctaglabel'
    c.native.send_keys ','
    c.native.send_keys 'xyz'
    c.native.send_keys ','
    page.find('#tags-list-submit').click
    
    assert '/readability/list', page.current_path
    assert page.has_content? 'abctaglabel'
  end
end

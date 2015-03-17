require 'test_helper'

class DeleteStatusesTest < Capybara::Rails::TestCase
  include Rack::Test::Methods
  def app
    Rails.application
  end

  def setup
    visit '/statuses'
  end
  
  test 'delete works' do
    assert page.has_content?('too old')
    
    page.assert_selector(:xpath, './/input[@type="submit" and @value="Clean"]', count: 1)
    page.click_button 'Clean'
    
    assert page.has_no_content?('too old')
  end
end

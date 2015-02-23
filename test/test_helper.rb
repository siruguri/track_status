ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

require 'simplecov'
require 'rails/test_help'

# For Reddit testing
require 'webmock/minitest'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.

  fixtures :all
  def fixture_file(filename)
    open(File.join(Rails.root, 'test', 'fixtures', 'files', filename)).readlines.join ''
  end
end

class ActionController::TestCase
  # Let controller test cases open files
  def fixture_file(filename)
    open(File.join(Rails.root, 'test', 'fixtures', 'files', filename)).readlines.join ''
  end
end

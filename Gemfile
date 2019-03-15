source 'https://rubygems.org'
ruby '2.6.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'
# Use SCSS for stylesheets
gem 'sass-rails'
gem 'jquery-ui-rails'
gem 'httparty'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
gem 'underscore-rails'

# No issue found that references possible bug in update to 3, possibly interacting with something else.
gem 'sprockets'
gem 'thin'

gem 'devise'
gem 'js-routes'

gem 'newrelic_rpm'
gem 'pg'

group :production do
  gem 'execjs'
end

gem 'dotenv'

# Everybody gotta have some Bootstrap!
gem 'jquery-rails'
gem 'bootstrap-sass'
gem 'rails-backbone'

gem 'haml'
gem 'json'
gem 'sendgrid-ruby'

gem 'redis-namespace'
gem 'sidekiq'
# Required for sidekiq monitoring
gem 'sinatra', :require => nil

# Reddit scraping
gem 'nokogiri'
gem 'web-console', ">3.0", group: :development

gem 'twilio-ruby'
group :development, :test do
  # Use sqlite3 as the database for Active Record in dev and test envs  
  gem 'pry'
  gem 'pry-remote'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  gem 'rails-controller-testing'
end

group :test do
  gem 'selenium-webdriver'
  gem 'capybara-webkit'
  gem 'mocha'
  gem 'simplecov'
  gem 'webmock'
  gem 'minitest-spec-rails'
  gem 'minitest-rails-capybara'
end

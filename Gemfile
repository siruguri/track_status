source 'https://rubygems.org'
ruby '2.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', ">=5.0"
# Use SCSS for stylesheets
gem 'sass-rails', ">=5.0"
gem 'jquery-ui-rails'

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

gem 'redis-namespace'
gem 'sidekiq'
# Required for sidekiq monitoring
gem 'sinatra', :require => nil

# Reddit scraping
gem 'nokogiri'
gem 'web-console', ">3.0", group: :development

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

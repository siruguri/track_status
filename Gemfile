source 'https://rubygems.org'
ruby '2.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# No issue found that references possible bug in update to 3, possibly interacting with something else.
gem 'sprockets', '~> 2'

gem 'devise'

gem 'js-routes'

group :production do
  gem 'pg'
  gem 'execjs'
end

gem 'quiet_assets'
gem 'dotenv'

# Everybody gotta have some Bootstrap!
gem 'jquery-rails'
gem 'bootstrap-sass'

gem 'haml'
gem 'json'

gem 'sidekiq'
# Required for sidekiq monitoring
gem 'sinatra', :require => nil

# Reddit scraping
gem 'nokogiri'
gem 'twitter'

group :development, :test do
  # Use sqlite3 as the database for Active Record in dev and test envs  
  gem 'sqlite3'
  
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'capistrano'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'

  # Can unset when https://github.com/phusion/passenger/issues/1392 is closed.
  gem 'capistrano-passenger', '0.0.2'
  gem 'capistrano-sidekiq'
end

group :test do
  gem 'poltergeist'
  gem 'mocha'
  gem 'simplecov'
  gem 'webmock'
  gem 'minitest-spec-rails'
  gem 'minitest-rails-capybara'
  gem 'capybara-webkit'
end

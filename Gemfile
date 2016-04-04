source 'https://rubygems.org'
ruby '2.3.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~>4.2'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
gem 'jquery-ui-rails'

gem 'activerecord-import'

# No issue found that references possible bug in update to 3, possibly interacting with something else.
gem 'sprockets', '~> 2'
gem 'thin'

gem 'devise'

gem 'js-routes'

gem 'newrelic_rpm'
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
gem 'oauth'

gem 'web-console', '~> 2.0', group: :development

group :development, :test do
  # Use sqlite3 as the database for Active Record in dev and test envs  
  gem 'sqlite3'
  gem 'pry'
  gem 'pry-remote'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
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
end

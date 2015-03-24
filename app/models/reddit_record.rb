class RedditRecord < ActiveRecord::Base
  serialize :user_info, Scrapers::RedditScraper::RedditUserInfo
end

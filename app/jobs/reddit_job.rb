class RedditJob < ActiveJob::Base
  queue_as :scrapers

  def perform(reddit_obj)
    userinfo = Scrapers::RedditScraper.new.user_info(reddit_obj.username)
    unless userinfo and userinfo.extracted?
      # No user found or extraction failed.
      if userinfo.nil?
        userinfo = Scrapers::RedditScraper::RedditUserInfo.new(error: "No such Reddit username")
      else
        userinfo = Scrapers::RedditScraper::RedditUserInfo.new(error: "Extraction code failed. Please contact sys admin.")
      end
    end
    reddit_obj.update_attributes(user_info: userinfo, extraction_in_progress: false)
    reddit_obj.save
  end
end

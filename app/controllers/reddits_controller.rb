class RedditsController < ApplicationController
  # Controller for actions to scrape Reddit
  
  def userinfo
    username = params[:user]
    @user = RedditRecord.find_by_username(username)

    if @user.nil?
      # No such user in DB - create one
      userinfo = Scrapers::RedditScraper.new.user_info(username)

      if userinfo and userinfo.extracted?
        @user = RedditRecord.create(username: username, user_info: userinfo)
        # Render userinfo
      else
        # No user found or extraction failed.
        if userinfo.nil?
          flash[:error] = "No such Reddit username"
        else
          flash[:error] = "Extraction code failed. Please contact sys admin."
        end
        render "application/blank_page"
      end
    end

    # render userinfo if user was found in DB
  end
end

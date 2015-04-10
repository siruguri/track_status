class RedditsController < ApplicationController
  # Controller for actions to scrape Reddit
  
  def userinfo
    username = params[:user]
    @user = RedditRecord.find_by_username(username)

    if @user.nil?
      # No such user in DB - schedule a job to create one
      @user = RedditRecord.new(username: username, extraction_in_progress: true)
      @user.save
      RedditJob.perform_later(@user)

      @message = :job_started
    else
      # TODO there's a 3rd poss state of the job being in progress, prior to being extracted
      @message = :extracted
    end
  end
end

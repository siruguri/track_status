class ReadabilityController < ApplicationController

  def run_scrape
    # All jobs in Sidekiq queue run in the last 24 hours
    all_jobs = JobRecord.where(job_name: 'ReadabilityJob').where('created_at > ?', Time.now - 1.minute)

    unless all_jobs.size > 0
      @message = 'job created'
      job = ReadabilityJob.perform_later('aldaily')
      JobRecord.create(job_id: job.job_id, status: 'running', job_name: 'ReadabilityJob')
    else
      @message = "previous job scheduled at #{all_jobs[0].created_at}, id = #{all_jobs[0].job_id}"
    end
  end

  def list_articles
    @offset = params[:start] ? params[:start].to_i : 0
    @article = WebArticle.order(created_at: :desc).offset(@offset).limit(1).first

    render :list
  end
end

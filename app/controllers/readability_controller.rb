class ReadabilityController < ApplicationController
  def tag_words
    if params[:id].nil? || (w = WebArticle.find_by_id(params[:id])).nil?
      render json: []
    else
      render json: w.top_bigrams
    end
  end

  def run_scrape
    # All jobs in Sidekiq queue run in the last 24 hours
    all_jobs = JobRecord.where(job_name: 'ReadabilityJob').where('created_at > ?', Time.now - 24.hours)

    unless params[:force_job]!='yes' and (Time.now.wday == 0 || all_jobs.size > 0)
      job = ReadabilityJob.perform_later('aldaily')
      j = JobRecord.create(job_id: job.job_id, status: 'running', job_name: 'ReadabilityJob')
      @message = "job created with ID #{j.id}"
    else
      if Time.now.wday == 0
        @message = "No jobs - today is Sunday"
      else
        @message = "previous job scheduled at #{all_jobs[0].created_at}, id = #{all_jobs[0].job_id}"
      end
    end
  end

  def list_articles
    @offset = params[:start] ? params[:start].to_i : 0
    @article = WebArticle.order(created_at: :desc).offset(@offset).limit(1).first

    render :list
  end
end

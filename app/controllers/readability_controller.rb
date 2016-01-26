class ReadabilityController < ApplicationController
  def tag_words
    sort_score = params[:sort_by] || 'unigram_boosted'
    if params[:id].nil? || (w = WebArticle.find_by_id(params[:id])).nil?
      render json: []
    else
      render json: (x=w.top_grams(sort_score))
    end
  end
  def tag_article
    offset = params[:start] ? params[:start].to_i : 0
    
    tag_list = params[:token_list].split(/,/)
    a = nil
    tag_list.each do |t|
      t = ArticleTag.find_or_create_by label: t
      begin 
        a = WebArticle.find params[:article_id_tag].to_i
      rescue ActiveRecord::RecordNotFound => e
        a = WebArticle.first
      end
      
      unless a.tags.where(label: t.label).count != 0
        a.tags << t
      end
    end

    redirect_to readability_list_path(start: offset)
  end
  
  def run_scrape
    # All jobs in Sidekiq queue run in the last 24 hours - use 23 as a buffer for cron jobs
    # To work.
    all_jobs = JobRecord.where(job_name: 'ReadabilityJob').where('created_at > ?', Time.now - 23.hours)

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

    source_sql = params[:site] ? "= ?" : "is null"
    @articles = WebArticle.where("source #{source_sql}", params[:site]).
                order(updated_at: :desc).offset(@offset > 0 ? @offset - 1 : @offset).
                limit(@offset > 0 ? 3 : 2)

    @prev = @offset == 0 ? -1 : @offset - 1
    @next = @articles.count > 1 ? @offset + 1 : -1
    
    if @articles.count == 0
      @article = WebArticle.new original_url: 'no uri', body: 'no body'
    elsif @offset == 0
      @article = @articles[0]
    else
      @article = @articles[1]
    end
    
    render :list
  end
end

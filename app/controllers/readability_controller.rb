class ReadabilityController < ApplicationController

  def run_scrape
    # All jobs in Sidekiq queue run in the last 24 hours
    aldaily_jobs = Sidekiq::Queue.new(:scrapers).select do |j|
      j.args[0]['job_class'] == 'ReadabilityJob' and Time.now - j.enqueued_at < 24.hours
    end

    unless aldaily_jobs.size > 0
      @message = 'job created'
      ReadabilityJob.perform_later('aldaily')
    else
      @message = "previous job scheduled at #{aldaily_jobs[0].enqueued_at}"
    end

  end
end

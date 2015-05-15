class JobRecordsController < ApplicationController
  def index
    @job_records = JobRecord.order(created_at: :desc).limit(20)
  end
end


require 'test_helper'

class ReadabilityControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper

  describe 'Readability job queue' do
    it 'runs a job once per day' do 
      assert_enqueued_with(job: ReadabilityJob, queue: 'scrapers', args: ['aldaily']) do
        get :run_scrape, site: 'aldaily'
      end

      assert_match /job created/i, response.body
      
      # A job is only run once a day
      assert_no_enqueued_jobs do
        get :run_scrape, site: 'aldaily'
      end
      
      assert_match /previous job/i, response.body
    end

    it 'updates the scrape record' do
      get :run_scrape, site: 'aldaily'

      assert_difference('ReadabilityRecord.count', 3) do
        perform_enqueued_jobs { ReadabilityJob.perform_now('aldaily') }
      end
    end
  end
end

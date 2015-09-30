require 'test_helper'
require 'webmock/minitest'

class ReadabilityJobTest < ActiveSupport::TestCase
  def setup
    stub_request(:get, "https://www.readability.com/api/content/v1/parser").
      with(query: hash_including({format: 'json', token: 'testreadabilityapikey', url: /^http/})).
      to_return(status: 200, body: fixture_file('readability-aldaily-file-1.html'),
                headers: {'Content-Type' => 'application/json; charset=utf-8'})
  end

  describe 'Running the job successfully' do
    before do
      stub_request(:get, 'http://www.aldaily.com/').
        to_return(body: fixture_file('aldaily-page.html'))
    end
    it "Gets articles" do
      assert_difference('WebArticle.count', 3) do
        ReadabilityJob.perform_now(:aldaily)
      end

      w = WebArticle.last
      assert_equal 'http://www.nytimes.com/2015/04/12/education/edlife/12edl-12mfa.html',
                   w.original_url
    end
  end

  describe "Readability failure" do
    before do
      stub_request(:get, 'http://www.aldaily.com/').
        to_return(body: fixture_file('aldaily-page-error-1.html'))
    end

    it "Sets the job status in the database" do

      JobRecord.create(job_id: 'fixed job id', status: 'running')
      ReadabilityJob.any_instance.stubs(:job_id).returns('fixed job id')
      ReadabilityJob.perform_now(:aldaily)

      j = JobRecord.last
      assert_match /fail.*at\s/i, j.status
    end
  end
end

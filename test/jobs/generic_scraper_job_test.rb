require 'test_helper'

class GenericScraperJobTest < ActiveSupport::TestCase
  def setup
    @initial_job_record_count = JobRecord.count
  end
                              
  test 'handles dom failures' do
    AnyScraper.any_instance.stubs(:create_payload).raises Scrapers::DomFailure.new('failed_patt')
    GenericScraperJob.perform_now(DummyDbRecord.new, 'AnyScraper')
    @expected_status = /fail/i
  end
  
  test 'handles socket failure' do
    AnyScraper.any_instance.stubs(:create_payload).raises SocketError
    GenericScraperJob.perform_now(DummyDbRecord.new, 'AnyScraper')
    @expected_status = /fail/i
  end
  
  test 'successful execution works' do
    AnyScraper.any_instance.stubs(:create_payload).with.returns true
    AnyScraper.any_instance.stubs(:payload).returns({ratings: [1,2,3]})
    AnyScraper.any_instance.stubs(:post_process_payload).returns true

    d = DummyDbRecord.new
    GenericScraperJob.perform_now(d, 'AnyScraper')

    assert_equal 3, d.ratings.size
    @expected_status = /success/i
  end
  
  def teardown
    assert_equal @initial_job_record_count + 1, JobRecord.count
    assert_match @expected_status, JobRecord.last.status
  end    
end

require 'test_helper'

class TwitterJobsTest < Capybara::Rails::TestCase
  include ActiveJob::TestHelper

  def setup
    Capybara.current_driver = :rack_test
    visit '/twitter/input_handle'
  end
  
  test 'Followers job can be started' do
    assert_enqueued_with(job: TwitterFetcherJob) do
      fill_in 'twitter-handle', with: 'twitter_handle_1'
      click_button 'Populate followers'
    end

    assert_equal 'twitter_handle_1', GlobalID::Locator.locate(enqueued_jobs[0][:args][0]['_aj_globalid']).handle
  end

  test 'uncrawled profiles processing can be started' do
    assert_enqueued_with(job: TwitterFetcherJob) do
      click_button 'uncrawled-profiles'
    end

    # Twice as many twitter_profiles that don't have tweets - right now, 7.
    assert_equal 2 * 7, enqueued_jobs.size
  end
end

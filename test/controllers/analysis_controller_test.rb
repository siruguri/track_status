require 'test_helper'

class AnalysisControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper
  
  test 'routing works' do
    assert_routing({method: :post, path: "/document_analyses/execute_task"},
                   {controller: 'analysis', action: 'execute_task'})
    assert_routing "/document_analyses/task_page", {controller: 'analysis', action: 'task_page'}
  end

  test 'document universe creation' do
    assert_difference('DocumentUniverse.count', 1) do
      post :execute_task, {commit: 'Compute Document Universe'}
    end
  end

  test 'update profile stats' do
    assert_difference('ProfileStat.count', TwitterProfile.where('handle is not null').count - ProfileStat.count) do
      post :execute_task, {commit: 'Update Profile Stats'}
    end
  end

  test 'reprocess all profiles' do
    assert_enqueued_with(job: TwitterFetcherJob) do
      post :execute_task, {commit: "Re-bio All Handles"}
    end

    assert_equal TwitterProfile.count, enqueued_jobs.size
    assert_match /: processed/i, flash[:notice]
  end
end

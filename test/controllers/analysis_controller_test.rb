require 'test_helper'

class AnalysisControllerTest < ActionController::TestCase
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
    assert_difference('ProfileStat.count', 4) do
      post :execute_task, {commit: 'Update Profile Stats'}
    end
  end
end

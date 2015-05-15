require 'test_helper'

class JobRecordsControllerTest < ActionController::TestCase
  test 'routes exist' do
    assert_routing '/job_records', {controller: 'job_records', action: 'index'}
  end

  test 'gets the job records' do
    get :index
    assert assigns(:job_records)
    j = assigns(:job_records)

    assert_equal 3, j.size
    assert_equal 'failed', j[0].status
  end
end

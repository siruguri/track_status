require 'test_helper'

class ReanalyzeEmailsJobTest < ActiveSupport::TestCase
  def setup
  end

  describe 'Running the job successfully' do
    before do
    end
    it "reanalyzes everything" do
      assert_difference('ArticleTag.count', 2) do
        ReanalyzeEmailsJob.perform_now
      end
    end
  end
end

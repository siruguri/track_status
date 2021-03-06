require 'test_helper'
require 'webmock/minitest'

class ReadabilityJobTest < ActiveSupport::TestCase
  describe 'Running the job successfully' do
    before do
  # Aldaily
      stub_request(:get, /.readability.com.*parser.*economist/).
        to_return(status: 200, body: fixture_file('readability-aldaily-file-2.html'),
                  headers: {'Content-Type' => 'application/json; charset=utf-8'})
      stub_request(:get, /.readability.com.*parser.*spectator/).
        to_return(status: 200, body: fixture_file('readability-aldaily-file-1.html'),
                  headers: {'Content-Type' => 'application/json; charset=utf-8'})
      stub_request(:get, /.readability.com.*parser.*aeon/).
        to_return(status: 200, body: fixture_file('readability-aldaily-file-3.html'),
                  headers: {'Content-Type' => 'application/json; charset=utf-8'})

      stub_request(:get, 'http://www.aldaily.com/').
        to_return(body: fixture_file('aldaily-page.html'))
    end
    
    it "Gets articles" do
      assert_difference('WebArticle.count', 3) do
        ReadabilityJob.perform_now(:aldaily)
      end

      w = WebArticle.last
      assert_match /www.commentarymagazine.com.article.the.moral.urgency.of.anna.karenina/,
                   w.original_url
    end
  end
end

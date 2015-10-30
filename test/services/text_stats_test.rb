require 'test_helper'

class TextStatsTest < ActiveSupport::TestCase
  def setup
    @doc = 'http://t.co/ogabaga1 is a good one isnt good it isnt now good'
  end

  test 'basic doc parsing' do
    assert_equal [["good", 3], ["isnt", 2], ["ogabaga1", 1]], TextStats::DocumentModel.new(@doc).sorted_counts
    assert_equal [["good", 3], ["isnt", 2]], TextStats::DocumentModel.new(@doc, twitter: true).sorted_counts
  end
end

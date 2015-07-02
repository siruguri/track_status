require 'test_helper'

class RtMovieEntryTest < ActiveSupport::TestCase
  def setup
    @model = rt_movie_entries(:entry1)
  end
  test '#save_payload!' do
    assert_equal 0, RtMovieEntry.find(@model.id).ratings.size
    @model.save_payload!({ratings: ['5', '3', 5, '1']})
    assert @model.persisted?
    
    assert_equal 4, RtMovieEntry.find(@model.id).ratings.size
  end
end
  

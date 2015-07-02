class RtMovieEntry < ActiveRecord::Base
  serialize :ratings, Array

  def uri
    original_uri
  end

  def save_payload!(payload)
    self.ratings = payload[:ratings]
    self.save!
  end
end

class CreateRtMovieEntries < ActiveRecord::Migration
  def change
    create_table :rt_movie_entries do |t|
      t.string :original_uri
      t.string :movie_title
      t.string :ratings

      t.timestamps
    end
  end
end

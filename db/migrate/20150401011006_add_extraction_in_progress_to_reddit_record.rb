class AddExtractionInProgressToRedditRecord < ActiveRecord::Migration
  def change
    add_column :reddit_records, :extraction_in_progress, :boolean
  end
end

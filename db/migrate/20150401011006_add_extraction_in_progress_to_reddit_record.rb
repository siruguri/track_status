class AddExtractionInProgressToRedditRecord < ActiveRecord::Migration[4.2]
  def change
    add_column :reddit_records, :extraction_in_progress, :boolean
  end
end

class AddProcessedToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :processed, :boolean
  end
end

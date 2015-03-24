class CreateRedditRecord < ActiveRecord::Migration
  def change
    create_table :reddit_records do |t|
      t.string :username
      t.text :user_info

      t.timestamps
    end
  end
end

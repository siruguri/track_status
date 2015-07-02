class CreateScraperRegistrations < ActiveRecord::Migration
  def change
    create_table :scraper_registrations do |t|
      t.string :db_model
      t.string :scraper_class

      t.timestamps
    end
  end
end

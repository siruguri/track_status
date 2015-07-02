class CreateScraperRequests < ActiveRecord::Migration
  def change
    create_table :scraper_requests do |t|
      t.string :uri

      t.timestamps
    end
  end
end

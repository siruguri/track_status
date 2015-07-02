class AddScraperRegistrationIdToScraperRequest < ActiveRecord::Migration
  def change
    add_column :scraper_requests, :scraper_registration_id, :integer
  end
end

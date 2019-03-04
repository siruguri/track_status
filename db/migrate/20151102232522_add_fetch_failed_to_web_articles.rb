class AddFetchFailedToWebArticles < ActiveRecord::Migration[4.2]
  def change
    add_column :web_articles, :fetch_failed, :boolean
  end
end

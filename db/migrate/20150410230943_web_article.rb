class WebArticle < ActiveRecord::Migration[4.2]
  def change
    create_table :web_articles do |t|
      t.string :source
      t.text :body

      t.timestamps
    end
  end
end

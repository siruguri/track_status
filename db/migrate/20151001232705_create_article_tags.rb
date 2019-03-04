class CreateArticleTags < ActiveRecord::Migration[4.2]
  def change
    create_table :article_tags do |t|
      t.string :label

      t.timestamps
    end
  end
end

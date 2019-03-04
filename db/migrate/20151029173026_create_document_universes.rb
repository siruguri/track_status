class CreateDocumentUniverses < ActiveRecord::Migration[4.2]
  def change
    create_table :document_universes do |t|
      t.text :universe

      t.timestamps
    end
  end
end

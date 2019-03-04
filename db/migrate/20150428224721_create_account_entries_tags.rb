class CreateAccountEntriesTags < ActiveRecord::Migration[4.2]
  def change
    create_table :account_entries_tags do |t|
      t.integer :transaction_tag_id
      t.integer :account_entry_id

      t.timestamps
    end
  end
end

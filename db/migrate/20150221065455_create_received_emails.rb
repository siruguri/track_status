class CreateReceivedEmails < ActiveRecord::Migration[4.2]
  def change
    create_table :received_emails do |t|
      t.string :source
      t.text :payload

      t.timestamps null: false
    end
  end
end

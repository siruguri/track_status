class CreateReceivedEmails < ActiveRecord::Migration
  def change
    create_table :received_emails do |t|
      t.string :source
      t.text :payload

      t.timestamps null: false
    end
  end
end

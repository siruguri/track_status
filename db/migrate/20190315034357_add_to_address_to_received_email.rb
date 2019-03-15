class AddToAddressToReceivedEmail < ActiveRecord::Migration[5.2]
  def change
    add_column :received_emails, :to_address, :string
    add_index :received_emails, :to_address, name: 'index_to_address_on_received_emails'
  end
end

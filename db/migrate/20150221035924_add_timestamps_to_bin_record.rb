class AddTimestampsToBinRecord < ActiveRecord::Migration[4.2]
  def change
    add_column :bin_records, :created_at, :datetime
    add_column :bin_records, :updated_at, :datetime
  end
end

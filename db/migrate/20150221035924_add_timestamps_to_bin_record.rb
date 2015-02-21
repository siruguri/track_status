class AddTimestampsToBinRecord < ActiveRecord::Migration
  def change
    add_column :bin_records, :created_at, :datetime
    add_column :bin_records, :updated_at, :datetime
  end
end

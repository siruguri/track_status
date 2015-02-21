class ChangeTimestampDataTypes < ActiveRecord::Migration
  def change
    change_column :bin_records, :created_at, :timestamp
    change_column :bin_records, :updated_at, :timestamp
    change_column :statuses, :created_at, :timestamp
    change_column :statuses, :updated_at, :timestamp
  end
end

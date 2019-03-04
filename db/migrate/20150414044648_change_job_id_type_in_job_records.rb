class ChangeJobIdTypeInJobRecords < ActiveRecord::Migration[4.2]
  def change
    change_column :job_records, :job_id, :string
  end
end

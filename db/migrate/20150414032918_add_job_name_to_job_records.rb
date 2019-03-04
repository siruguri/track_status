class AddJobNameToJobRecords < ActiveRecord::Migration[4.2]
  def change
    add_column :job_records, :job_name, :string
  end
end

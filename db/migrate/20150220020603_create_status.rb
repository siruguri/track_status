class CreateStatus < ActiveRecord::Migration[4.2]
  def change
    create_table :statuses do |t|
      t.string :source
      t.string :description
      t.text :message
    end
  end
end

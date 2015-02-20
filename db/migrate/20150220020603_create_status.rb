class CreateStatus < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :source
      t.string :description
      t.text :message
    end
  end
end

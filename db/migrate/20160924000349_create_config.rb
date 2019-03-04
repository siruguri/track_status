class CreateConfig < ActiveRecord::Migration[4.2]
  def change
    create_table :configs do |t|
      t.string :config_key
      t.text :config_value
      t.string :config_value_type
    end
  end
end

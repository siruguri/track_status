class CreateBinRecord < ActiveRecord::Migration[4.2]
  def change
    create_table :bin_records do |t|
      t.string :number
      t.string :brand
      t.string :sub_brand
      t.string :country_code
      t.string :country_name
      t.string :bank
      t.string :card_type
      t.string :card_category
      t.float :lat
      t.float :long
    end
  end
end

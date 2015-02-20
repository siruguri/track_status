class BinRecord < ActiveRecord::Base
  validates :number, :brand, :bank, presence: true
end

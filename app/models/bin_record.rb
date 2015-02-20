class BinRecord < ActiveRecord::Base
  validates :number, presence: true
end

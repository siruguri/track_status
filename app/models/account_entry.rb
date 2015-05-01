class AccountEntry < ActiveRecord::Base
  has_many :account_entries_tags
  has_many :transaction_tags, through: :account_entries_tags

  validates :entry_date, :entry_amount, :merchant_name, presence: true
  validates :entry_amount, numericality: {greater_than_or_equal_to: 0}
  
  def self.untagged
    includes(:account_entries_tags).where(account_entries_tags: {account_entry_id: nil})
  end
    
end

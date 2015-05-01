class AccountEntriesTag < ActiveRecord::Base
  belongs_to :account_entry
  belongs_to :transaction_tag
end

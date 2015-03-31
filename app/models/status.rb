class Status < ActiveRecord::Base
  validates :source, :description, :message, presence: true
end

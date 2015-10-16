class ReceivedEmail < ActiveRecord::Base
  serialize :payload, Array
end

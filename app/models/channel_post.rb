class ChannelPost < ActiveRecord::Base
  validates :url, presence: true
  validates :message, presence: true
  
  serialize :post_strategy, PostStrategy
  serialize :tweet_tags, Array

  before_save :set_total_count

  private
  def set_total_count
    if new_record?
      self.total_post_count = 0
    end
  end
end

class WebArticle < ActiveRecord::Base
  # Store web articles scraped from the web
  include TextStatisticsAnalyzer

  has_many :article_taggings
  has_many :tags, through: :article_taggings, class_name: 'ArticleTag', source: :article_tag
  
  validate :original_url, :valid_uri?
  
  def valid_uri?
    if original_url =~ /\A#{URI::regexp(['http', 'https'])}\z/
      return true
    else
      errors.add(:base, 'Invalid URI supplied for source')
    end
  end
  
end

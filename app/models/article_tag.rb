class ArticleTag < ActiveRecord::Base
  has_many :article_taggings
  has_many :web_articles, through: :article_taggings
end

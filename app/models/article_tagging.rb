class ArticleTagging < ActiveRecord::Base
  belongs_to :article_tag
  belongs_to :web_article 
end

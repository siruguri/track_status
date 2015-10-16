class ReanalyzeEmailsJob < ActiveJob::Base
  # Class for all jobs related to doing a readability parse
  queue_as :reanalyses

  def uri_and_tags(s)
    h = {tags: DataProcessHelpers.extract_tags(s)}
    cand = DataProcessHelpers.hyperlink_pattern.match(s)
    h.merge({uri: cand ? cand[1] : nil})    
  end

  def perform
    ReceivedEmail.all.map do |email|
      payload = email.payload[0]['msg']['raw_msg']

      uri_tag = uri_and_tags(payload)
      uri_tag[:tags].each do |t|
        if w = WebArticle.find_by_original_url(uri_tag[:uri])
          unless ArticleTagging.joins(:article_tag).where(web_article: w, article_tags: {label: t}).count > 0
            t = ArticleTag.find_or_create_by(label: t)
            ArticleTagging.create web_article: w, article_tag: t
          end
        end
      end
    end
  end
end

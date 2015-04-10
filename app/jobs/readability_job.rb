class ReadabilityJob < ActiveJob::Base
  # Class for all jobs related to doing a readability parse
  queue_as :scrapers

  def perform(site_key)
    # Only works for site_key = :aldaily
    payload = Scrapers::AldailyScraper.new.payload()

    if payload[:status] == 'success'
      parser = ReadabilityParserWrapper.new
      bodies = payload[:links].map do |uri|
        parser.parse(uri).content
      end

      bodies.each do |b|
        WebArticle.create(source: site_key, body: b)
      end
    end
  end
end

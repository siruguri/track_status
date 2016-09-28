class ReadabilityJob < ActiveJob::Base
  # Class for all jobs related to doing a readability parse
  queue_as :scrapers

  def perform(site_key)
    # Only works for site_key = 'aldaily'

    payload = Scrapers::AldailyScraper.new.payload()

    if payload[:status] == 'success'
      parser = ReadabilityParserWrapper.new

      readability_resps = payload[:links].map do |uri|
        parser.parse(uri.value)
      end.compact

      readability_resps.each do |resp|
        w = WebArticle.new(original_url: resp.url, source: site_key, body: resp.content)
        saved = false
        while !saved
          begin
            w.save!
          rescue SQLite3::BusyException => e
            sleep 5 unless Rails.env.test?
          else
            saved = true
          end
        end
      end

      status = 'finished'
    else
      status = "failed: #{payload[:status]}"
    end
  end
end

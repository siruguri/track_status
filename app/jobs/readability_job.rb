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
      end
      readability_resps.each do |resp|
        puts "#{resp.url} might not pass"
        w = WebArticle.new(original_url: resp.url, source: site_key, body: resp.content)
        w.save!
      end

      status = 'finished'
    else
      status = "failed: #{payload[:status]}"
    end

    if (j = JobRecord.find_by_job_id self.job_id)
      j.status = status
      j.save
    end
  end
end

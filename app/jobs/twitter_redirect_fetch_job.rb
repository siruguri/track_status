class TwitterRedirectFetchJob < ActiveJob::Base
  queue_as :scrapers

  def perform(web_article)
    # Twitter URLs have a 301 redirect
    return if web_article.body.present?
    actual_url = ''
    begin
      u = URI(web_article.original_url)

      # Handle redirects if necessary
      if u.host == 't.co'
        request = Net::HTTP::Get.new u
        request.add_field('Accept-Encoding', 'none')
        resp = nil
        conn = Net::HTTP.new(u.host, u.port)
        conn.use_ssl = true if u.scheme == 'https'

        conn.start do
          resp = conn.request request
        end

        if resp.code == '301'
          actual_url = resp.header['location']
        end
      else
        actual_url = web_article.original_url
      end

      # Abort if we didn't get a redirect from Twitter
      unless actual_url.blank?
        parser = ReadabilityParserWrapper.new
        body = parser.parse(actual_url).try(:content)
        # Hourly allowance = 1000
        sleep 4 unless Rails.env.test?
        
        if !body.blank? and !(body.is_a? Hash)
          # We only save the body when it's retrieved from Readability - sometimes Readability fails
          Rails.logger.debug "--- Retrieved #{body.size} bytes of data"
          web_article.body = body
          web_article.save!
          
          # Rate limit this job if it saves a new body
          sleep 3
        else
          web_article.body = body[:failure_message]
          web_article.save!
        end
      end
    rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT, Timeout::Error, Errno::ECONNRESET, SocketError,
           Errno::EINVAL, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e2
      web_article.update_attributes({fetch_failed: false})
    end
  end
end


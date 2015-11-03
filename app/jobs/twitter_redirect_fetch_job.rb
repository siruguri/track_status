class TwitterRedirectFetchJob < ActiveJob::Base
  queue_as :scrapers

  def perform(web_article)
    # Twitter URLs have a 301 redirect
    return if web_article.body.present?
    
    u = URI(web_article.original_url)

    request = Net::HTTP::Get.new u
    body = ''
    resp = nil
    conn = Net::HTTP.new(u.host, u.port)
    conn.use_ssl = true if u.scheme == 'https'

    begin
      conn.start do
        resp = conn.request request
      end

      if resp.code == '301'
        parser = ReadabilityParserWrapper.new
        body = parser.parse(resp.header['location']).try(:content)
      end
    rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT, Timeout::Error, Errno::ECONNRESET, SocketError,
           Errno::EINVAL, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e2
      web_article.update_attribute fetch_failed: false
    end
    
    if !body.blank?
      # We only save the body when it's retrieved
      Rails.logger.debug "--- Retrieved #{body.size} bytes of data"
      web_article.body = body
      web_article.save!

      # Rate limit this job if it saves a new body
      sleep 2
    end
  end
end


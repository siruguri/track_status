class ReadabilityParserWrapper
  class ReadabilityBody
    attr_reader :content, :url
    def initialize(content:, url:)
      @content = content
      @url = url
    end
  end
  
  def initialize
    @_key = ENV['READABILITY_API_KEY']
  end

  def parse(uri_string)
    uri = URI "https://www.readability.com/api/content/v1/parser?format=json&token=#{@_key}&url=#{uri_string}"

    response = ''
    Net::HTTP.start(uri.host, uri.port,
                    use_ssl: true) do |http|
      request = Net::HTTP::Get.new uri
      response = http.request request
    end

    body = JSON.parse response.body
    ReadabilityBody.new(content: body['content'], url: body['url'])
  end
end

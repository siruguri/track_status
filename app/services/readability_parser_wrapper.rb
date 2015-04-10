class ReadabilityParserWrapper
  def initialize
    @_key = ENV['READABILITY_API_KEY']
    @_client = ReadabilityParser::Client.new(api_token: @_key)
  end

  def parse(uri)
    @_client.parse(uri)
  end
end

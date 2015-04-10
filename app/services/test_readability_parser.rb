require 'readability_parser'
require_relative './readability_parser_wrapper'

k = ReadabilityParserWrapper.new.parse 'http://www.the-tls.co.uk/tls/public/article1541210.ece'

puts k.content

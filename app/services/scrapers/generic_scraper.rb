require 'open-uri'

module Scrapers
  class GenericScraper
    attr_reader :payload
    def initialize(uri_string=nil)
      @uri_string = uri_string
      @payload = nil
    end
    
    def get_dom(link = nil)
      return nil if link.nil? && @uri_string.nil?
      if link.nil? and @_dom
          return @_dom
      end

      handle = open (link.nil? ? @uri_string : link)
      @_dom = SafeDom.new(Nokogiri::HTML.parse(handle.readlines.join('')))
    end

    def create_payload
      get_dom
      # Default payload
      @payload = {title: get_dom.try_css('title').text}

      if (self.respond_to?(:payload_map))
        payload_map[:data].each do |rule|
          begin
            elts = @_dom.try_css(rule[:pattern])
          rescue DomFailure => e
          else
            @payload[rule[:value]] = []
            elts.each do |elt|
              if elt.respond_to? :text
                @payload[rule[:value]] << elt.text.strip
              end
            end
          end
        end
      end
      
      @payload
    end

    def scrape_later(rt_movie_rec)
      klass_string = self.class.to_s

      GenericScraperJob.perform_later(rt_movie_rec, klass_string)
    end
  end
end

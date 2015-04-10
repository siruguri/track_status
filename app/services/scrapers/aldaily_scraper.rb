require 'open-uri'

module Scrapers
  class AldailyScraper < GenericScraper
    # Scraper for the AL Daily.com page
    def payload
      @_safe_d = get_dom('http://www.aldaily.com')

      begin
        ret = {status: 'success'}.merge(extract_top3_articles)
      rescue DomFailure => e
        ret = {status: 'failure'}
      end

      ret
    end

    private
    def extract_top3_articles
      link_divs = []
      link_divs <<  @_safe_d.try_css('span.articles-of-note')[0]
      link_divs <<  @_safe_d.try_css('span.new-books')[0]
      link_divs <<  @_safe_d.try_css('span.essays-and-opinion')[0]

      refs = link_divs.map do |d|
        link = SafeDom.new(d).try_css('a')
        link.attribute('href')
      end

      {links: refs}
    end
  end
end

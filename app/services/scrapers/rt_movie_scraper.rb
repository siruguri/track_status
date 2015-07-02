module Scrapers
  class RtMovieScraper < GenericScraper
    def payload_map
      @payload_map ||=
      {data: [{pattern: '#all-critics-numbers span[itemprop=ratingValue]',
               value: :allcrits_tomato_score},
              {pattern: '#top-critics-numbers span[itemprop=ratingValue]',
               value: :topcrits_tomato_score}],
       links: [{pattern: 'table.info span[itemprop=genre]',
                value: :genre_list,
                scraper_job_class: 'RT_Genre_Scraper'}]}
    end

    def post_process_payload
      payload[:ratings] = payload[:allcrits_tomato_score] + payload[:topcrits_tomato_score]
    end
  end    
end

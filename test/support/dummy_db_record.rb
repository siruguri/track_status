class DummyDbRecord
  attr_reader :ratings

  def uri
    'http://someuri'
  end
  def save_payload!(hash)
    @ratings = hash[:ratings]
  end

  def self.create(opts={})
    @count ||= 0
    @count += 1
  end

  def self.count
    @count ||= 0
  end
end

class AnyScraper < Scrapers::GenericScraper
end
  

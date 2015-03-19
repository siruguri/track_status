module Scrapers
  class DomFailure < Exception
    def initialize(p)
      @_failed_patt = p
    end
    
    def message
      "Extraction failed at #{@_failed_patt}"
    end
  end
end

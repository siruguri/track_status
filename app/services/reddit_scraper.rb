require 'open-uri'

class RedditScraper
  class SafeDom
    # Wrapper class to implement parser management
    def initialize(dom_or_ns)
      @_dom_or_ns = dom_or_ns
    end
    
    def try_css(patt)
      @_dom_or_ns.css patt
    end
  end

  class RedditUserInfo
    # Manage scraped data before storing to db
    def initialize
      @_store = {submitted_links: 0, entries: [], subreddit_counts: {}}
    end

    def aggregate!(hash)
      if hash[:submitted_links]
        @_store[:submitted_links] += hash[:submitted_links]
      end

      if hash[:entries]
        @_store[:entries] += hash[:entries]
      end

      @_store[:entries].each do |entry_hash|
        @_store[:subreddit_counts]["#{entry_hash[:subreddit]}.#{entry_hash[:post_type]}"] ||= 0
        @_store[:subreddit_counts]["#{entry_hash[:subreddit]}.#{entry_hash[:post_type]}"] += 1
      end
    end

    def [](key)
      @_store[key]
    end
  end

  def initialize
    @userinfo = RedditUserInfo.new   
  end
  
  def user_info(username)
    begin 
      f=open("http://www.reddit.com/user/#{username}/")
    rescue OpenURI::HTTPError => e
      return nil
    end
    
    pg_queue = [f]

    while pg_queue.compact.size > 0
      @dom = get_dom(pg_queue.shift)
      pg_queue << next_page_link
      
      @userinfo.aggregate!(extract_userinfo)
    end

    @userinfo
  end

  private
  def next_page_link
    # If the user page has a next link return it else return nil (might work for other pages)

    candidate = @dom.try_css('.nextprev a')
    if candidate.count > 0 and /next/.match(candidate.first.text)
      candidate.first.attribute('href').value
    else
      nil
    end
  end

  def extract_userinfo
    # Get user info
    things = @dom.try_css('.linklisting .thing')

    user_hash = {}
    things.each do |thing|
      thing_type = /comment/.match(thing.attribute('class')) ? :comment : :post
      thing_subreddit = SafeDom.new(thing).try_css('a.subreddit').text
      user_hash[:entries] ||= []
      user_hash[:entries] << {type: thing_type, subreddit: thing_subreddit}
    end
    user_hash.merge({submitted_links: things.count})
  end
  
  def get_dom(input)

    if input.is_a? String
      handle = open(input)
    else
      handle = input
    end
    SafeDom.new(Nokogiri::HTML.parse(handle.readlines.join('')))
  end
  
end

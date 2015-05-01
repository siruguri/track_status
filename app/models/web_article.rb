class WebArticle < ActiveRecord::Base
  # Store web articles scraped from the web
  
  validate :original_url, :valid_uri?

  def word_array
    body.gsub(/<\/?[^>]+>/, ' ').gsub(/[^a-zA-Z]/, ' ').split(/\s+/)
  end
  def top_bigrams
    bigrams = {}
    all_words = word_array
    # Use a hash to count the occurrences of bigrams
    all_words.each_with_index do |word, idx|
      if idx < word_array.size - 1
        bigrams["#{word} #{word_array[idx+1]}"] ||= 0
        bigrams["#{word} #{word_array[idx+1]}"] += 1        
      end
    end

    resp = []

    x=(bigrams.inject([]) do |memo, item|
       # convert the counts hash to an array
       memo << {value: item[0], count: item[1]}
     end.sort do |a, b|
       # Sort the array by the counts of each bigram, desc
      b[:count] <=> a[:count]
       end)

    x[0..4].each_with_index do |item, idx|
      # Keep the top 5.
      resp << ({id: idx, name: item[:value]})
    end

    resp
  end
  
  def valid_uri?
    if original_url =~ /\A#{URI::regexp(['http', 'https'])}\z/
      return true
    else
      errors.add(:base, 'Invalid URI supplied for source')
    end
  end
  
end

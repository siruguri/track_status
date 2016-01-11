module TwitterHelper
  def remove_entities_and_numbers(w)
    !(/\A\d+\Z/.match(w[0]) || /^\#/.match(w[0]) || /^\@/.match(w[0]))
  end
    
  def number_of_tweets_message(profile)
    if (stat = profile.profile_stat)
      ": #{stat.stats_hash['total_tweets']} tweets retrieved, " +
        "retweet average = #{sprintf("%0.2f", stat.stats_hash['retweeted_avg'])}, " +
        "total retweets = #{stat.stats_hash['retweet_aggregate']}, in #{(@handles_by_tweets[profile.handle])} attempts"
    else
      ": No tweets retrieved"
    end
  end
  
  def nice_date(dt)
    dt.strftime "%Y-%m-%d %H:%M"
  end
  def word_display(w, divisor)
    "#{w[0]}: #{sprintf("%0.3g", w[1]*100/divisor)} [#{sprintf("%0.3g", (@orig_word_explanations[w[0]+'.tf']||1)*100)}, #{sprintf("%0.3g", (@orig_word_explanations[w[0]+'.idf']||1)*100)}]"
  end
  def twitter_cloud_box_partial(type, title_text)
    word_list =
      case type
      when :webdocs
        divisor = @webdocs_count
        @webdocs_word_cloud
      when :retweets
        divisor = @tweets_count - @orig_tweets_count
        @retweets_word_cloud.select { |w| remove_entities_and_numbers w }
      when :all
        divisor = @tweets_count
        @all_word_cloud.select { |w| remove_entities_and_numbers w }
      when :orig
        divisor = @orig_tweets_count
        words = @orig_word_cloud.select { |w| remove_entities_and_numbers w }
        words
      when :hashtags
        divisor = @tweets_count
        (@orig_word_cloud + @all_word_cloud).select { |w| /^\#/.match(w[0])}.sort_by { |p| -p[1]}.uniq { |i| i[0] }
      when :handles
        divisor = @tweets_count
        (@orig_word_cloud + @all_word_cloud).select { |w| /^\@/.match(w[0]) && w[0] != '@'}.sort_by { |p| -p[1]}.uniq { |i| i[0] }
      end

    render partial: 'twitter_cloud_box',
           locals: {word_list: word_list.slice(0..25),
                    list_type_title: title_text, divisor: divisor}
  end
end

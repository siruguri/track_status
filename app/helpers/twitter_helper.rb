module TwitterHelper
  def nice_date(dt)
    dt.strftime "%Y-%m-%d %H:%M"
  end
  def word_display(w, divisor)
    "#{w[0]}: #{sprintf("%0.3g", w[1]*100/divisor)}"
  end
  def twitter_cloud_box_partial(type, title_text)
    word_list =
      case type
      when :retweets
        divisor = @tweets_count - @orig_tweets_count
        @retweets_word_cloud.select { |w| !(/^\#/.match(w[0]) || /^\@/.match(w[0]))}
      when :all
        divisor = @tweets_count
        @all_word_cloud.select { |w| !(/^\#/.match(w[0]) || /^\@/.match(w[0]))}
      when :orig
        divisor = @orig_tweets_count
        @orig_word_cloud.select { |w| !(/^\#/.match(w[0]) || /^\@/.match(w[0]))}
      when :hashtags
        divisor = @tweets_count
        (@orig_word_cloud + @all_word_cloud).select { |w| /^\#/.match(w[0])}.sort_by { |p| -p[1]}.uniq { |i| i[0] }
      when :handles
        divisor = @tweets_count
        (@orig_word_cloud + @all_word_cloud).select { |w| /^\@/.match(w[0]) && w[0] != '@'}.sort_by { |p| -p[1]}.uniq { |i| i[0] }
      end

    render partial: 'twitter_cloud_box',
           locals: {word_list: word_list.slice(0..15),
                    list_type_title: title_text, divisor: divisor}
  end
end

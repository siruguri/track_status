module TwitterHelper
  def nice_date(dt)
    dt.strftime "%Y-%m-%d %H:%M"
  end
  def word_display(w)
    "#{w[0]}: #{sprintf("%0.3g", w[1])}"
  end
  def twitter_cloud_box_partial(type, title_text)
    word_list =
      case type
      when :all
        @all_word_cloud.select { |w| !(/^\#/.match(w[0]) || /^\@/.match(w[0]))}
      when :orig
        @orig_word_cloud.select { |w| !(/^\#/.match(w[0]) || /^\@/.match(w[0]))}
      when :hashtags
        (@orig_word_cloud + @all_word_cloud).select { |w| /^\#/.match(w[0])}.sort_by { |p| -p[1]}
      when :handles
        (@orig_word_cloud + @all_word_cloud).select { |w| /^\@/.match(w[0])}.sort_by { |p| -p[1]}
      end

    render partial: 'twitter_cloud_box',
           locals: {word_list: word_list.slice(0..15),
                    list_type_title: title_text}
  end
end

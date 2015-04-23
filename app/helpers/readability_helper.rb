module ReadabilityHelper
  def domain_name(url)
    matches = /http.?.\/\/(www.)?([^\/\.]+)/.match url

    if matches
      matches[2]
    else
      url || 'no url'
    end
  end
end

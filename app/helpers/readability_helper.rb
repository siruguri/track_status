module ReadabilityHelper
  def domain_name(url)
    matches = /http.?.\/\/(www.)?([^\/\.]+)/.match url
    domain = matches[2]

    domain
  end
end

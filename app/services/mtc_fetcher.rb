class MtcFetcher
  attr_reader :stop_id, :arrivals, :route_name, :title
  def initialize(stop_id, name, title)
    @stop_id = stop_id
    @route_name = name
    @title = title
  end

  def arrivals
    # Return Array
    # Assumes httparty

    url = "https://proxy-prod.511.org/api-proxy/api/v1/transit/stop/?stopcode=#{stop_id}"
    data = JSON.parse(HTTParty.get(url).body)
    @arrivals = data.dig('Routes', 0, 'Routes').select do |route_hash|
      route_hash['Name'] == @route_name
    end[0]['Departures'].map { |s| s.to_i }
  end

  def send_n_mails(n, opts = {})
    interval = opts[:interval] || 1
    n.times.each do |i|
      sendmail
      sleep interval.minutes
    end
  end
  
  def sendmail
    MtcMailer.alert_id(Struct.new(:id, :name).new(stop_id, title), arrivals).deliver
  end
end

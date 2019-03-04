class MtcFetcherJob < ActiveJob::Base
  queue_as :default

  def arrivals(stop_id, route_name)
    # Return Array
    # Assumes httparty

    url = "https://proxy-prod.511.org/api-proxy/api/v1/transit/stop/?stopcode=#{stop_id}"
    data = JSON.parse(HTTParty.get(url).body)
    data.dig('Routes', 0, 'Routes').select do |route_hash|
      route_hash['Name'] == route_name
    end[0]['Departures'].map { |s| s.to_i }
  end

  def perform(stop_id, name, title, n, opts = {})
    interval = opts[:interval] || 1
    n.times.each do |i|
      sendmail stop_id, title, name
      sleep interval.minutes
    end
  end
  
  def sendmail(stop_id, title, route_name)
    MtcMailer.alert_id(Struct.new(:id, :name).new(stop_id, title), arrivals(stop_id, route_name)).deliver_now
  end
end

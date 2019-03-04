class MtcController < ApplicationController
  def fetch_and_mail
    @arrivals = []
    @available_stops = available_stops
    # force an error to investigate appsignal

    if params[:error_force]
      nowthisis_500
    end
    if params[:mtc_id]
      id = params[:mtc_id]
      @title = @available_stops.select { |s| s.id.to_s == id }.first.display_name
      # It's important that the params value here is a String
      m = MtcFetcher.new(id, params[:mtc_name], @title)
      @arrivals = m.arrivals

      unless params[:stop_email]
        m.delay.send_n_mails(10, interval: 1)
      end
    end
  end

  private

  def available_stops
    [['62, to BART', 50553, 62], ['40, leaving home', 55336, 40],
     ['14, leaving work', 54457, 14], ['1 Leaving work', 57777, 1]
    ].map do |(name, id, code)|
      Struct.new(:display_name, :id, :code_name).new name, id, code
    end
  end
end

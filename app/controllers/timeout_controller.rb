class TimeoutController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:infinite_loop]

  def infinite_loop
    sleep 10000
    render nothing: true
  end
end

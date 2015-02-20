class BindbController < ApplicationController
  # Process bins
  skip_before_filter :verify_authenticity_token

  def add
    render 'pages/success'
  end

end

class EmailController < ApplicationController
  # Email controller
  
  skip_before_filter :verify_authenticity_token

  def transform

    if params[:mandrill_events]
      r=ReceivedEmail.new(source: 'mandrill', payload: params[:mandrill_events])
      r.save
      render 'pages/success'
    else
      render 'pages/fail', status: 400
    end
  end
end

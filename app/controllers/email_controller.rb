class EmailController < ApplicationController
  # Email controller

  skip_before_filter :verify_authenticity_token

  def transform
    if params[:mandrill_events]
      r=ReceivedEmail.new(source: 'mandrill', payload: params[:mandrill_events])
      r.save

      GeneralMailer.notification_email(payload: params[:mandrill_events].inspect).deliver_later

      body = params[:mandrill_events][0]['msg']['raw_msg']
      m = /(http.?:\/\/[^\s]+)/.match body
      uri = m[1]
      if uri
        parser = ReadabilityParserWrapper.new
        resp = parser.parse uri
        w = WebArticle.create(original_url: resp.url, body: resp.content)
      end

      render 'pages/success'
    else
      render 'pages/fail', status: 400
    end
  end
end

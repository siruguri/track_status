class EmailController < ApplicationController
  # Email controller

  skip_before_filter :verify_authenticity_token

  def transform
    if params[:mandrill_events]
      mandrill_hash = JSON.parse params[:mandrill_events]

      r=ReceivedEmail.create(source: 'mandrill', payload: params[:mandrill_events])
      GeneralMailer.notification_email(payload: params[:mandrill_events]).deliver_later

      if mandrill_hash.size > 0 and mandrill_hash[0]['msg'] and
        mandrill_hash[0]['msg']['raw_msg']
        body = mandrill_hash[0]['msg']['raw_msg']
        m = /(http.?:\/\/[^\s]+)/.match body
        uri = m[1]
        if uri
          parser = ReadabilityParserWrapper.new
          resp = parser.parse uri
          w = WebArticle.create(original_url: resp.url, body: resp.content)
        end
      end
      render 'pages/success'
    else
      render 'pages/fail', status: 400
    end
  end
end

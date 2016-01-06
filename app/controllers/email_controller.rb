class EmailController < ApplicationController
  # Email controller

  skip_before_filter :verify_authenticity_token

  def reanalyze
    ReanalyzeEmailsJob.perform_later
    render 'pages/success'
  end

  def transform
    if params[:dev_body]
      GeneralMailer.notification_email(payload: params[:dev_body]).deliver_later
      render 'pages/success'
    elsif params[:mandrill_events]
      mandrill_hash = JSON.parse params[:mandrill_events]

      r=ReceivedEmail.create(source: 'mandrill', payload: JSON.parse(params[:mandrill_events]))
      GeneralMailer.notification_email(payload: params[:mandrill_events]).deliver_later

      if mandrill_hash.size > 0 and mandrill_hash[0]['msg'] and
        mandrill_hash[0]['msg']['raw_msg']
        body = mandrill_hash[0]['msg']['raw_msg']
        m = DataProcessHelpers.hyperlink_pattern.match body
        if m
          uri = m[1]
          parser = ReadabilityParserWrapper.new
          resp = parser.parse uri
          if resp
            w = WebArticle.create(original_url: resp.url, body: resp.content)
          end
        end
      end
      render 'pages/success'
    else
      render 'pages/fail', status: 400
    end
  end
end

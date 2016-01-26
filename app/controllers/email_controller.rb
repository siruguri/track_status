class EmailController < ApplicationController
  # Email controller

  skip_before_filter :verify_authenticity_token

  def reanalyze
    ReanalyzeEmailsJob.perform_later
    render 'pages/success'
  end

  def transform
    mandrill_hash = params[:mandrill_events] ? JSON.parse(params[:mandrill_events]) : nil
    if params[:dev_body] 
      GeneralMailer.notification_email(payload: params[:dev_body]).deliver_later
      render 'pages/success'
    elsif params[:wildcard] == 'true'
      if body = (mandrill_body mandrill_hash)
        GeneralMailer.notification_email(payload: body, type: 'wildcard').deliver_later
      end
      render 'pages/success'
    elsif params[:mandrill_events]

      r=ReceivedEmail.create(source: 'mandrill', payload: mandrill_hash)
      GeneralMailer.notification_email(payload: mandrill_hash).deliver_later

      if body = mandrill_body(mandrill_hash)
        m = DataProcessHelpers.hyperlink_pattern.match body
        if m
          uri = m[1]
          parser = ReadabilityParserWrapper.new

          w = WebArticle.new 
          w.original_url = uri
          begin
            resp = parser.parse uri
            if resp
              w.body = resp.content
            end
          rescue Exception => e
            w.body = e.message
          end
        end
      end
      render 'pages/success'
    else
      render 'pages/fail', status: 400
    end
  end

  private
  def mandrill_body(mandrill_hash)
    if mandrill_hash.size > 0 and mandrill_hash[0]['msg'] and
      mandrill_hash[0]['msg']['raw_msg']
      return mandrill_hash[0]['msg']['raw_msg']
    else
      return nil
    end
  end
end

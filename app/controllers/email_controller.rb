class EmailController < ApplicationController
  # Email controller
  class MailServicePayload
    attr_reader :source, :body
    def initialize(source, body)
      @source = source
      @body = body
    end
  end
  
  skip_before_filter :verify_authenticity_token

  def reanalyze
    ReanalyzeEmailsJob.perform_later
    render 'pages/success'
  end

  def transform
    mail_svc_hash = params[:mandrill_events] ? JSON.parse(params[:mandrill_events]) : params.to_unsafe_hash
    if params[:dev_body] 
      GeneralMailer.notification_email(payload: params[:dev_body]).deliver_later
      render 'pages/success'
    else
      payload = mail_payload(mail_svc_hash)
      if payload
        r=ReceivedEmail.create(source: payload.source, payload: (mail_svc_hash.is_a?(Array) ? mail_svc_hash : [mail_svc_hash]))
        GeneralMailer.notification_email(payload: mail_svc_hash).deliver_later

        # Retrieve first string match on a URL like string
        m = DataProcessHelpers.hyperlink_pattern.match payload.body
        if m
          uri = m[1]
          parser = ReadabilityParserWrapper.new

          w = WebArticle.find_or_initialize_by original_url: uri
          begin
            resp = parser.parse uri
            if resp
              w.body = resp.content
            end
          rescue Exception => e
            w.body = e.message
          end

          w.save
        end
        render 'pages/success'
      else
        render 'pages/fail', status: 400
      end
    end
  end

  private
  def mail_payload(mail_service_hash)
    if mail_service_hash.is_a?(Array) and mail_service_hash[0]['msg'] and
      mail_service_hash[0]['msg']['raw_msg']
      # This is the Mandrill format
      return MailServicePayload.new('mandrill', mail_service_hash[0]['msg']['raw_msg'])
    elsif mail_service_hash['email']
      # This is the Sendgrid format
      return MailServicePayload.new('sendgrid', mail_service_hash['email'])
    else
      return nil
    end
  end
end

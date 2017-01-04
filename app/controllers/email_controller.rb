class EmailController < ApplicationController
  # Email controller
  include SendgridManager
  
  class MailServicePayload
    attr_reader :source, :fields
    def initialize(source, hash)
      @source = source
      @fields = make_fields hash
    end

    private
    def make_fields(hash)
      case @source
      when 'sendgrid'
        return {body: hash['text'],
                html_body: hash['html'],
                subject: hash['subject'],
                to: hash['to'],
                from: hash['from']}
      when 'sparkpost'
        sparkpost_base = hash['_json'][0]['msys']['relay_message']['content']
        return {body: sparkpost_base['text'],
                html_body: sparkpost_base['html'],
                subject: sparkpost_base['subject'],
                to: sparkpost_base['to']}
      else
        return {body: 'cannot parse'}
      end
    end
  end
  
  skip_before_action :verify_authenticity_token

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
      if payload.source != 'unknown'
        r=ReceivedEmail.create(source: payload.source, payload: (mail_svc_hash.is_a?(Array) ? mail_svc_hash : [mail_svc_hash]))
        GeneralMailer.notification_email(fields: payload.fields).deliver_later

        # Retrieve first string match on a URL like string
        m = DataProcessHelpers.hyperlink_pattern.match payload.fields[:body]
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
        mail_svc_hash['source'] = 'unknown'
        GeneralMailer.notification_email(payload: mail_svc_hash).deliver_later
        render 'pages/fail', status: 200
      end
    end
  end

  def send_it
    test_email
    head :ok
  end
    
  private
  def mail_payload(mail_service_hash)
    if mail_service_hash.is_a?(Array) and mail_service_hash[0]['msg'] and
      mail_service_hash[0]['msg']['raw_msg']
      # This is the Mandrill format
      return MailServicePayload.new('mandrill', mail_service_hash[0]['msg']['raw_msg'])
    elsif mail_service_hash['text']
      # This is the Sendgrid format
      return MailServicePayload.new('sendgrid', mail_service_hash)
    elsif mail_service_hash['html']
      # This is the Sendgrid format
      return MailServicePayload.new('sendgrid', mail_service_hash)
    elsif mail_service_hash.dig('_json', 0, 'msys')
    # This is from Sparkpost
      return MailServicePayload.new('sparkpost', mail_service_hash)
    else
      return MailServicePayload.new('unknown', mail_service_hash)
    end
  end
end

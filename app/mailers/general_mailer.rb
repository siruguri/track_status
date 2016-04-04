class GeneralMailer < ActionMailer::Base
  default from: 'siruguri@gmail.com'
  
  def notification_email(opts={})
    opts = opts.with_indifferent_access
    
    @payload = opts[:payload] || ''

    opts[:to] ||= 'siruguri@gmail.com'
    
    subject = 'sendgrid deliver: info@siruguri.net'
    mail to: opts[:to], subject: subject
  end
end

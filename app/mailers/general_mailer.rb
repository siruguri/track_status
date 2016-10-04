class GeneralMailer < ActionMailer::Base
  default from: 'siruguri@gmail.com'
  
  def notification_email(opts = {})
    # fields points to a hash with special keys - see view :(
    opts[:to] ||= 'siruguri@gmail.com'

    if opts[:fields].nil?
      opts[:fields] = {subject: 'fields not recd', body: 'fields not recd'}
    end
    @fields = opts[:fields]
    
    subject = 'webhook receipt notice: siruguri -> siruguri'
    mail to: opts[:to], subject: subject
  end
end

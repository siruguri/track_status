class GeneralMailer < ActionMailer::Base
  default from: 'siruguri@gmail.com'
  
  def notification_email(opts = {})
    # fields points to a hash with special keys - see view :(
    opts[:to] ||= 'siruguri@gmail.com'

    if opts[:fields].nil?
      opts[:fields] = {subject: 'fields not recd - see JSON in body', body: 'fields not recd'}
      if opts[:payload]
        opts[:fields][:body] += "\nJSON is: #{opts[:payload].to_json}"
      end
    end
    @fields = opts[:fields]
    
    subject = 'webhook receipt notice: siruguri -> siruguri'
    mail to: opts[:to], subject: subject
  end
end

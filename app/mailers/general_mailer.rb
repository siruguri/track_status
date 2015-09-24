class GeneralMailer < ActionMailer::Base
  default from: 'siruguri@gmail.com', subject: 'Mandrill deliver: info@siruguri.net'
  
  def notification_email(to: 'siruguri@gmail.com', payload: '')
    @payload = payload
    mail to: to
  end
end

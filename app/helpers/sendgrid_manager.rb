module SendgridManager
  include SendGrid
  def test_email
    from = Email.new(email: 'x+y@mail.offtherailsapps.com')
    subject = 'Hello World from the SendGrid Ruby Library!'
    to = Email.new(email: 'siruguri@gmail.com')
    content = Content.new(type: 'text/plain', value: 'Hello, Email!')
    
    mail = Mail.new(from, subject, to, content)
    sg = SendGrid::API.new api_key: Rails.application.secrets.sendgrid_api_key
    
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers
  end
end

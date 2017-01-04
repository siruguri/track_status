#require 'twilio-ruby'
module TwilioManager
  # put your own credentials here
  def send_message
    account_sid = Rails.application.secrets.twilio_account_sid_prod
    auth_token = Rails.application.secrets.twilio_auth_token_prod

    # alternatively, you can preconfigure the client like so
    Twilio.configure do |config|
      config.account_sid = account_sid
      config.auth_token = auth_token
    end

    # and then you can create a new client without parameters
    client = Twilio::REST::Client.new

    #Send an SMS

    @client.messages.create(
      from: '+15102101842',
      to: '+16509960998',
      body: 'Hey there!'
    )
  end
end

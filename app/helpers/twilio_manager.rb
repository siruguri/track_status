require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'twilio-ruby'

# put your own credentials here
account_sid = 'ACe66587fb8a9d87a7609e732fe6e43980'
auth_token = 'cb5eb67bef8448912543f0b05b2de7f0'


account_sid = 'ACc902915030a8e9dc7b69c7ef4995ad22'
auth_token = '188206f8db9606549e798d4b3edaf193'

# set up a client to talk to the Twilio REST API
@client = Twilio::REST::Client.new account_sid, auth_token

# alternatively, you can preconfigure the client like so
Twilio.configure do |config|
  config.account_sid = account_sid
  config.auth_token = auth_token
end

# and then you can create a new client without parameters
@client = Twilio::REST::Client.new

#Send an SMS

@client.messages.create(
  from: '+15102101842',
  to: '+16509960998',
  body: 'Hey there!'
)

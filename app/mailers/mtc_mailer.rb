class MtcMailer < ActionMailer::Base
  default from: 'siruguri@gmail.com'
  def alert_id(stop_data, arrivals)
    @arrivals = arrivals
    mail to: 'sameers.public@gmail.com',
         subject: "Arrivals at #{stop_data.name} (##{stop_data.id})", skip_log: true
  end
end

class MailJob < Que::Job
  include RecipientSelector

  def run
    complete_registration_recipients.each do |recipient|
      Rails.logger.debug "MailJob: Sending to #{recipient.email}"
      NotifyMailer.complete_registration(recipient)
    end
  end
end

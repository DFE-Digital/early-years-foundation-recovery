class MailJob < Que::Job
  include RecipientSelector

  def run
    complete_registration_recipients.each do |recipient|
      NotifyMailer.complete_registration(recipient)
    end

    start_training_recipients.each do |recipient|
      NotifyMailer.start_training(recipient)
    end
  end
end

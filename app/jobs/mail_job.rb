class MailJob < Que::Job
  include RecipientSelector

  def run
    log 'MailJob: Running'
    complete_registration_recipients.each do |recipient|
      NotifyMailer.complete_registration(recipient)
    end

    start_training_recipients.each do |recipient|
      NotifyMailer.start_training(recipient)
    end

    continue_training_recipients.each do |recipient|
      NotifyMailer.continue_training(recipient, module_in_progress(recipient))
    end
  end
end

class MailJob < Que::Job
  include RecipientSelector

  def run
    complete_registration_recipients.each do |recipient|
      NotifyMailer.complete_registration(recipient)
    end

    start_training_recipients.each do |recipient|
      NotifyMailer.start_training(recipient)
    end

    continue_training_recipients.each do |recipient|
      NotifyMailer.continue_training(recipient, module_in_progress(recipient))
    end

    if new_module.present?
      new_module_recipients(new_module).each do |recipient|
        NotifyMailer.new_module(recipient, new_module)
      end
    end
  end
end

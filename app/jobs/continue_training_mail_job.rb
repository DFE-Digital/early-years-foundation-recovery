class ContinueTrainingMailJob < MailJob
  def run
    super do
      self.class.recipients.each do |recipient|
        recipient.modules_in_progress.each do |mod_name|
          mod = Training::Module.by_name(mod_name)
          recipient.send_continue_training_notification(mod)
        end
      end
    end
  end
end

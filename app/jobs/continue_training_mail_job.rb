class ContinueTrainingMailJob < MailJob
  # @return [void]
  def run
    super do
      notify_users
      log_mail_job
    end
  end

  def recipients
    User.continue_training_recipients
  end

private

  # @return [void]
  def notify_users
    recipients.each do |recipient|
      recipient.send_continue_training_notification(recipient.courses_in_progress.first)
    end
  end
end

class StartTrainingMailJob < MailJob
  # @return [void]
  def run
    super do
      notify_users
      log_mail_job
    end
  end

  def recipients
    User.start_training_recipients
  end

private

  # @return [void]
  def notify_users
    recipients.each(&:send_start_training_notification)
  end
end

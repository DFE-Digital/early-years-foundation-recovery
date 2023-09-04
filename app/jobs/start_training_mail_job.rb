class StartTrainingMailJob < MailJob
  # @return [Array<User>]
  def self.recipients
    User.start_training_recipients
  end

  def run
    super do
      self.class.recipients.each(&:send_start_training_notification)
    end
  end
end

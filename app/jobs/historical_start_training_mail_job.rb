class HistoricalStartTrainingMailJob < MailJob
  def run
    super do
      self.class.recipients.each(&:send_start_training_notification)
    end
  end
end

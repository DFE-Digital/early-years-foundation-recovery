class HistoricalCompleteRegistrationMailJob < MailJob
  def run
    super do
      self.class.recipients.each(&:send_complete_registration_notification)
    end
  end
end

class CompleteRegistrationMailJob < MailJob
  # @return [Array<User>]
  def self.recipients
    User.complete_registration_recipients
  end

  def run
    super do
      self.class.recipients.each(&:send_complete_registration_notification)
    end
  end
end

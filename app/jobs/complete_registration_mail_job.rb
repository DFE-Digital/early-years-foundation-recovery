class CompleteRegistrationMailJob < MailJob
  def run
    super do
      self.class.recipients.find_each do |user|
        prepare_message(user)
      end
    end
  end
end

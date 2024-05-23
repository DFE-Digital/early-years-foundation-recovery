class StartTrainingMailJob < MailJob
  def run
    super do
      self.class.recipients.find_each do |user|
        deliver_message(user)
      end
    end
  end
end

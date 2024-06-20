# Sends mail for complete registration
# @note This queues up this job unless stated otherwise
class CompleteRegistrationMailJob < MailJob
  def run
    super do
      self.class.recipients.find_each do |user|
        prepare_message(user)
      end
    end
  end
end

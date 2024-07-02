# Sends mail for start training
# @note email delivery is queued unless DELIVERY_QUEUE=false
class StartTrainingMailJob < MailJob
  def run
    super do
      self.class.recipients.find_each do |user|
        prepare_message(user)
      end
    end
  end
end

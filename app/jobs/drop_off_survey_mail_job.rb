# Sends the drop-off survey to users inactive for two weeks.
# @note email delivery is queued unless DELIVERY_QUEUE=false
class DropOffSurveyMailJob < MailJob
  def run
    super do
      self.class.recipients.find_each do |user|
        next if user.completed_modules_available_at_last_progress?

        prepare_message(user)
      end
    end
  end
end

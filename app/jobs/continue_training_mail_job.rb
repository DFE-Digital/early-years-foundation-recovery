class ContinueTrainingMailJob < ApplicationJob
  # @return [void]
  def run
    super do
      notify_users
    end
  end

  def recipients
    User.continue_training_recipients
  end

private

  # @return [void]
  def notify_users
    recipients.each do |recipient|
      user.send_continue_training_notification(recipient.course_in_progress.first)
    end
  end
end

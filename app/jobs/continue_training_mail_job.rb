class ContinueTrainingMailJob < ApplicationJob
  # @return [void]
  def run
    super do
      notify_users
    end
  end

private

  # @return [void]
  def notify_users
    User.continue_training_recipients.each do |recipient|
      progress = recipient.course
      NotifyMailer.continue_training(recipient, progress.current_modules.first)
    end
  end
end

class StartTrainingMailJob < ApplicationJob
  # @return [void]
  def run
    super do
      notify_users
    end
  end

private

  # @return [void]
  def notify_users
    User.start_training_recipients.each { |recipient| NotifyMailer.start_training(recipient) }
  end
end

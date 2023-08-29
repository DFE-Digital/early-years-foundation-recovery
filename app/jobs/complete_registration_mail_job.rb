class CompleteRegistrationMailJob < ApplicationJob
  # @return [void]
  def run
    super do
      notify_users
    end
  end

  def recipients
    User.complete_registration_recipients
  end

private

  # @return [void]
  def notify_users
    recipients.each(&:send_complete_registration_notification)
  end
end

class CompleteRegistrationMailJob < ApplicationJob
  # @return [void]
  def run
    super do
      notify_users
    end
  end

private

  # @return [void]
  def notify_users
    User.complete_registration_recipients.each { |recipient| NotifyMailer.complete_registration(recipient) }
  end
end

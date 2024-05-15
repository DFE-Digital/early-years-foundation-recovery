class NotifyDelivery < GovukNotifyRails::Delivery
  # @param message [Mail::Message]
  # @return [Symbol, Array<Notifications::Client::ResponseNotification>]
  def deliver!(message)
    super
  rescue StandardError
    Sentry.capture_message "#{self.class.name} failed: '#{message.display}'", level: :info
    :skipped_due_to_error
  end
end

ActionMailer::Base.add_delivery_method(
  :govuk_notify,
  NotifyDelivery,
  api_key: ENV.fetch('GOVUK_NOTIFY_API_KEY', Rails.application.credentials.notify_api_key),
)

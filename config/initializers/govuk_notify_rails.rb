class NotifyDelivery < GovukNotifyRails::Delivery
  # Ensure delivery errors do not impede bulk mailout
  # @param message [Mail::Message]
  # @return [Symbol, Array<Notifications::Client::ResponseNotification>]
  def deliver!(message)
    super
  rescue StandardError
    message.display
    errors = message.errors.map { |e| "'#{e.last.message}'" }.join(', ')
    Sentry.capture_message("#{self.class.name} failed with #{errors}", level: :warn) unless Rails.application.live?
    :skipped_due_to_error
  end
end

ActionMailer::Base.add_delivery_method(
  :govuk_notify, NotifyDelivery, api_key: Rails.application.config.notify_token
)

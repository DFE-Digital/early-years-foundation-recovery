ActionMailer::Base.add_delivery_method(
  :govuk_notify,
  GovukNotifyRails::Delivery,
  api_key: ENV.fetch('GOVUK_NOTIFY_API_KEY', Rails.application.credentials.notify_api_key)
)

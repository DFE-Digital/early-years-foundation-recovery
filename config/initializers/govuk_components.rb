Govuk::Components.configure do |config|
  # config.brand = 'dfe'
  config.default_header_service_name = Rails.configuration.service_name
  config.default_phase_banner_phase = 'beta'
end

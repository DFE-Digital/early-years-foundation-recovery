require 'training/module'
require 'training/page'
require 'training/question'
require 'training/confidence'

ContentfulRails.configure do |config|
  # config.authenticate_webhooks = true # false here would allow the webhooks to process without basic auth
  # config.webhooks_username = 'ey_recovery'
  # config.webhooks_password = 'ey_recovery'
  config.enable_preview_domain = true
  config.preview_domain = ENV.fetch('DOMAIN', 'preview').split('.').first
  config.environment = Rails.application.credentials.dig(:contentful, :environment)
  config.access_token = Rails.application.credentials.dig(:contentful, :delivery_access_token) # Required
  config.space = Rails.application.credentials.dig(:contentful, :space) # Required
  config.preview_access_token = Rails.application.credentials.dig(:contentful, :preview_access_token) # Optional - required if you want to use the preview API
  config.management_token = Rails.application.credentials.dig(:contentful, :management_access_token) # Optional - required if you want to update or create content
  config.default_locale = 'en-US' # Optional - defaults to 'en-US'
  config.eager_load_entry_mapping = false
  config.contentful_options = {
    modules: ENV.fetch('CONTENTFUL_MODULES', 'child-development-and-the-eyfs,alpha').split(','),
    new_modules: ENV.fetch('NEW_CONTENTFUL_MODULES', 'module-6').split(','),
    delivery_api: { timeout_connect: 2, timeout_read: 6, timeout_write: 20 },
    management_api: { timeout_connect: 3, timeout_read: 100, timeout_write: 200 },
    entry_mapping: {
      'module' => Training::Module,
      'page' => Training::Page,
      'question' => Training::Question,
      'confidence' => Training::Confidence,
    },
  }
end

require 'training/module'
require 'training/page'
require 'training/question'
require 'training/video'
require 'contentful/static'

ContentfulRails.configure do |config|
  config.space            = Rails.application.config.contentful_space
  config.environment      = Rails.application.config.contentful_environment
  config.perform_caching  = Rails.application.live?
  config.default_locale   = 'en-US' # Optional - defaults to 'en-US'

  # Webhooks
  # config.authenticate_webhooks = true # false here would allow the webhooks to process without basic auth
  # config.webhooks_username = 'ey_recovery'
  # config.webhooks_password = 'ey_recovery'

  # Preview is enabled for local development and staging
  # config.enable_preview_domain =
  # config.preview_domain =

  # Tokens
  config.access_token         = Rails.application.config.contentful_delivery_access_token
  config.preview_access_token = Rails.application.config.contentful_preview_access_token
  config.management_token     = Rails.application.config.contentful_management_access_token

  config.eager_load_entry_mapping = false

  config.contentful_options = {
    delivery_api: { timeout_connect: 2, timeout_read: 6, timeout_write: 20 },
    management_api: { timeout_connect: 3, timeout_read: 100, timeout_write: 200 },
    entry_mapping: {
      'static' => Contentful::Static,
      'trainingModule' => Training::Module,
      'page' => Training::Page,
      'question' => Training::Question,
      'video' => Training::Video,
    },
  }
end

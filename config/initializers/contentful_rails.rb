require 'training/content'
require 'training/module'
require 'training/page'
require 'training/question'
require 'training/video'
require 'page'

# Preview enabled for local development and staging
ContentfulModel.use_preview_api = Rails.application.preview?

ContentfulRails.configure do |config|
  config.space            = Rails.application.config.contentful_space
  config.environment      = Rails.application.config.contentful_environment
  config.perform_caching  = Rails.env.production?
  config.default_locale   = 'en-US'

  # Webhooks
  config.authenticate_webhooks = true
  config.webhooks_username = 'ey_recovery'
  config.webhooks_password = 'ey_recovery'

  # Tokens
  config.access_token         = Rails.application.config.contentful_delivery_access_token
  config.preview_access_token = Rails.application.config.contentful_preview_access_token
  config.management_token     = Rails.application.config.contentful_management_access_token

  config.eager_load_entry_mapping = false

  config.contentful_options = {
    logger: Rails.logger,

    # Prevent recursion
    max_include_resolution_depth: 1,
    reuse_entries: true,

    # Timeout settings
    preview_api: { timeout_connect: 2, timeout_read: 6, timeout_write: 20 },
    delivery_api: { timeout_connect: 2, timeout_read: 6, timeout_write: 20 },
    management_api: { timeout_connect: 3, timeout_read: 100, timeout_write: 200 },

    entry_mapping: {
      'static' => Page,
      'trainingModule' => Training::Module,
      'page' => Training::Page,
      'question' => Training::Question,
      'video' => Training::Video,
    },
  }
end

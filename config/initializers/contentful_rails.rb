require 'management'
require 'caching'
require 'pagination'
require 'content_types'

require 'course'
require 'training/content'
require 'training/module'
require 'training/page'
require 'training/question'
require 'training/video'
require 'page'
require 'page/resource'
require 'trainee/setting'

Rails.application.config.active_job.custom_serializers << ::Training::Module::Serialiser

# Without this the value is nil and defaults to delivery API
ContentfulModel.use_preview_api = Rails.application.preview?

ContentfulRails.configure do |config|
  config.space            = Rails.application.config.contentful_space
  config.environment      = Rails.application.config.contentful_environment
  config.perform_caching  = Rails.env.production?
  config.default_locale   = 'en-US'

  # Tokens
  config.access_token         = Rails.application.config.contentful_delivery_access_token
  config.preview_access_token = Rails.application.config.contentful_preview_access_token
  config.management_token     = Rails.application.config.contentful_management_access_token

  # Preview
  config.enable_preview_domain = Rails.application.preview?

  config.eager_load_entry_mapping = false

  config.contentful_options = {
    logger: Rails.logger,

    # Prevent recursion
    max_include_resolution_depth: 1,
    reuse_entries: true,

    # Timeout settings (increased)
    preview_api: { timeout_connect: 10, timeout_read: 30, timeout_write: 60 },
    delivery_api: { timeout_connect: 10, timeout_read: 30, timeout_write: 60 },
    management_api: { timeout_connect: 10, timeout_read: 120, timeout_write: 240 },

    entry_mapping: {
      'userSetting' => Trainee::Setting,
      'static' => Page,
      'resource' => Page::Resource,
      'trainingModule' => Training::Module,
      'page' => Training::Page,
      'question' => Training::Question,
      'video' => Training::Video,
      'course' => Course,
    },
  }
end

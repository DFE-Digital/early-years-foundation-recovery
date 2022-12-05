require 'training/module'
require 'training/page'
require 'training/question'
require 'training/confidence'

ContentfulRails.configure do |config|
  config.authenticate_webhooks = true # false here would allow the webhooks to process without basic auth
  config.webhooks_username = ENV['CONTENTFUL_WEBHOOKS_USERNAME']
  config.webhooks_password = ENV['CONTENTFUL_WEBHOOKS_PASSWORD']
  config.access_token = ENV['CONTENTFUL_DELIVERY_ACCESS_TOKEN']
  config.preview_access_token = ENV['CONTENTFUL_PREVIEW_ACCESS_TOKEN']
  config.enable_preview_domain = true
  config.management_token = ENV['CONTENTFUL_MANAGEMENT_ACCESS_TOKEN']
  config.space = ENV['CONTENTFUL_SPACE']
  config.environment = 'master'
  config.eager_load_entry_mapping = false
  config.contentful_options = { 
    entry_mapping: {
      'module' => Training::Module,
      'page' => Training::Page,
      'question' => Training::Question,
      'confidence' => Training::Confidence
    }
  }
end
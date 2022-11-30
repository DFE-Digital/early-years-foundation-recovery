ContentfulModel.configure do |config|
  config.access_token = Rails.configuration.access_token # Required
  config.preview_access_token = Rails.configuration.preview_access_token # Optional - required if you want to use the preview API
  config.management_token = Rails.configuration.management_token # Optional - required if you want to update or create content
  config.space = Rails.configuration.space # Required
  config.environment = "master" # Optional - defaults to 'master'
  config.default_locale = "en-US" # Optional - defaults to 'en-US'
  config.options = { # Optional
    # Extra options to send to the Contentful::Client and Contentful::Management::Client
    # See https://github.com/contentful/contentful.rb#configuration

    # Optional:
    # Use `delivery_api` and `management_api` keys to limit to what API the settings
    # will apply. Useful because Delivery API is usually visitor facing, while Management
    # is used in background tasks that can run much longer. For example:
    delivery_api: { timeout_connect: 2, timeout_read: 6, timeout_write: 20 },
    management_api: { timeout_connect: 3, timeout_read: 100, timeout_write: 200 }
  }
end

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'grover'

ALLOWED_TAGS = %w[p ul li div ol strong].freeze

module EarlyYearsFoundationRecovery
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    # @see ErrorsController
    config.exceptions_app = routes

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.generators do |g|
      g.test_framework :rspec
    end

    config.bot_token = ENV['BOT_TOKEN']
    config.feedback_url = ENV.fetch('FEEDBACK_URL', '#FEEDBACK_URL_env_var_missing')
    config.google_analytics_tracking_id = ENV.fetch('TRACKING_ID', '#TRACKING_ID_env_var_missing')
    config.hotjar_site_id = ENV.fetch('HOTJAR_SITE_ID', '#HOTJAR_SITE_ID_env_var_missing')
    config.training_modules = ENV.fetch('TRAINING_MODULES', 'training-modules')
    config.unlock_in_minutes = ENV.fetch('UNLOCK_IN_MINUTES', '120').to_i
    config.user_timeout_minutes = ENV.fetch('TIMEOUT_MINUTES', '25').to_i
    # user_timeout_warning_minutes and user_timeout_modal_visible value combined must be lower than user_timeout_minutes
    config.user_timeout_warning_minutes = ENV.fetch('TIMEOUT_WARNING_MINUTES', '20').to_i
    config.user_timeout_modal_visible = ENV.fetch('TIMEOUT_MODAL_VISIBLE', '5').to_i
    config.service_name = 'Early years child development training'
    config.middleware.use Grover::Middleware
    config.active_record.yaml_column_permitted_classes = [Symbol]
    config.action_view.sanitized_allowed_tags = ALLOWED_TAGS

    config.access_token = ENV.fetch('CONTENTFUL_DELIVERY_ACCESS_TOKEN', '#CONTENTFUL_DELIVERY_ACCESS_TOKEN_env_var_missing')
    config.preview_access_token = ENV.fetch('CONTENTFUL_PREVIEW_ACCESS_TOKEN', '#CONTENTFUL_PREVIEW_ACCESS_TOKEN_env_var_missing') 
    config.management_token = ENV.fetch('CONTENTFUL_MANAGEMENT_ACCESS_TOKEN', '#CONTENTFUL_MANAGEMENT_ACCESS_TOKEN_env_var_missing') 
    config.space = ENV.fetch('CONTENTFUL_SPACE', '#CONTENTFUL_SPACE_env_var_missing')
  end
end

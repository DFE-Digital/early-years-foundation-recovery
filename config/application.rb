require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'grover'

module EarlyYearsFoundationRecovery
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.exceptions_app = self.routes # 404, 500 errors etc

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

    config.training_modules = ENV.fetch('TRAINING_MODULES', 'training-modules')
    config.feedback_url = ENV.fetch('FEEDBACK_URL', '#FEEDBACK_URL_env_var_missing')
    config.user_timeout_minutes = ENV.fetch('TIMEOUT_MINUTES', '15').to_i
    config.unlock_in_minutes = ENV.fetch('UNLOCK_IN_MINUTES', '120').to_i
    config.middleware.use Grover::Middleware
    config.active_record.yaml_column_permitted_classes = [Symbol]
    config.google_analytics_tracking_id = ENV.fetch('TRACKING_ID', '#TRACKING_ID_env_var_missing')
  end
end

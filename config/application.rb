require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EarlyYearsFoundationRecovery
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

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

    config.feedback_url = ENV.fetch('FEEDBACK_URL', 'https://forms.office.com/Pages/ResponsePage.aspx?id=yXfS-grGoU2187O4s0qC-Qjm3BfYzDVIhkQadsLBtTxUMk01Qlc1R0dKRUQ0WEpPUUFYVzdWRllXUCQlQCN0PWcu')
    config.user_timeout_minutes = ENV.fetch('TIMEOUT_MINUTES', '15').to_i
    config.unlock_in_minutes = ENV.fetch('UNLOCK_IN_MINUTES', '120').to_i
  end
end

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
    # config.eager_load_paths << Rails.root.join("extras")

    # causes log colting error when deploying a review app in GPaaS
    # config.time_zone = ENV.fetch('TZ', 'Europe/London')

    config.generators do |g|
      g.test_framework :rspec
    end

    config.service_name = 'Early years child development training'
    config.internal_mailbox = ENV.fetch('INTERNAL_MAILBOX', 'child-development.training@education.gov.uk')
    config.middleware.use Grover::Middleware
    config.active_record.yaml_column_permitted_classes = [Symbol]
    config.action_view.sanitized_allowed_tags = ALLOWED_TAGS

    # Background Jobs
    config.active_job.queue_adapter = :que
    config.action_mailer.deliver_later_queue_name = :default
    config.action_mailbox.queues.incineration = :default
    config.action_mailbox.queues.routing = :default
    config.active_storage.queues.analysis = :default
    config.active_storage.queues.purge = :default

    config.google_cloud_bucket = ENV.fetch('GOOGLE_CLOUD_BUCKET', '#GOOGLE_CLOUD_BUCKET_env_var_missing')
    config.dashboard_update_interval = ENV.fetch('DASHBOARD_UPDATE_INTERVAL', '0 0 * * *') # Midnight daily

    config.bot_token = ENV['BOT_TOKEN']
    config.feedback_url = ENV.fetch('FEEDBACK_URL', '#FEEDBACK_URL_env_var_missing')
    config.google_analytics_tracking_id = ENV.fetch('TRACKING_ID', '#TRACKING_ID_env_var_missing')
    config.hotjar_site_id = ENV.fetch('HOTJAR_SITE_ID', '#HOTJAR_SITE_ID_env_var_missing')

    config.unlock_in_minutes = ENV.fetch('UNLOCK_IN_MINUTES', '120').to_i
    config.user_timeout_minutes = ENV.fetch('TIMEOUT_MINUTES', '25').to_i
    # user_timeout_warning_minutes and user_timeout_modal_visible value combined must be lower than user_timeout_minutes
    config.user_timeout_warning_minutes = ENV.fetch('TIMEOUT_WARNING_MINUTES', '20').to_i
    config.user_timeout_modal_visible = ENV.fetch('TIMEOUT_MODAL_VISIBLE', '5').to_i

    # Contentful
    config.contentful_space                   = ENV.fetch('CONTENTFUL_SPACE', credentials.dig(:contentful, :space))
    config.contentful_delivery_access_token   = ENV.fetch('CONTENTFUL_DELIVERY_TOKEN', credentials.dig(:contentful, :delivery_access_token))
    config.contentful_preview_access_token    = ENV.fetch('CONTENTFUL_PREVIEW_TOKEN', credentials.dig(:contentful, :preview_access_token))
    config.contentful_management_access_token = ENV.fetch('CONTENTFUL_MANAGEMENT_TOKEN', credentials.dig(:contentful, :management_access_token)) # TODO: use service account management token
    config.contentful_environment             = ENV.fetch('CONTENTFUL_ENVIRONMENT', credentials.dig(:contentful, :environment))

    # @return [Boolean]
    def live?
      ENV['WORKSPACE'].eql?('production')
    end

    # @return [Boolean]
    def candidate?
      ENV['WORKSPACE'].eql?('staging')
    end

    # @return [Boolean]
    def main?
      ENV['WORKSPACE'].eql?('development')
    end

    # @return [Boolean]
    def review?
      ENV['WORKSPACE'].eql?('content')
    end

    # @return [Boolean] Upload to CSV files to the dashboard
    def dashboard?
      Types::Params::Bool[ENV.fetch('DASHBOARD_UPDATE', true)]
    end

    # TODO: refactor to use coerced type post CMS release
    #
    # CI workflow uses DELIVERY
    # CMS validation workflow uses PREVIEW then DELIVERY
    #
    # @see ContentfulRails.configuration.enable_preview_domain
    # @see ContentfulModel.use_preview_api
    #
    # @return [Boolean]
    def preview?
      if Rails.env.test? && ENV['CONTENTFUL_PREVIEW'].blank?
        false
      elsif ENV['CONTENTFUL_PREVIEW'].present?
        true
      else
        false
      end
    end

    # @return [Boolean]
    def debug?
      return ENV['DEBUG'] == 'true' if ENV['DEBUG'].present?

      Rails.env.development?
    end

    # @return [ActiveSupport::TimeWithZone]
    def public_beta_launch_date
      Time.zone.local(2023, 2, 9, 15, 0, 0)
    end

    # @return [ActiveSupport::TimeWithZone]
    def non_linear_launch_date
      Time.zone.local(2023, 7, 10, 15, 43, 0)
    end
  end
end

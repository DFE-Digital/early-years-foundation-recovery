require_relative 'boot'
require 'rails/all'

Bundler.require(*Rails.groups)

module EarlyYearsFoundationRecovery
  class Application < Rails::Application
    config.load_defaults 7.0
    # @see ErrorsController
    config.exceptions_app = routes

    config.generators do |g|
      g.test_framework :rspec
    end

    # config.eager_load_paths << Rails.root.join("extras")
    # config.time_zone = ENV.fetch('TZ', 'Europe/London')
    config.service_url = (Rails.env.production? ? 'https://' : 'http://') + ENV.fetch('DOMAIN', 'child-development-training')

    # @see #maintenance?
    # These endpoints are exempt from maintenance page redirection
    config.protected_endpoints = %w[
      /maintenance
      /health
      /change
      /release
      /notify
    ]

    config.middleware.use Grover::Middleware
    config.active_record.yaml_column_permitted_classes = [Symbol]
    config.action_view.sanitized_allowed_tags = %w[p ul li div ol strong].freeze

    # Background Jobs
    config.active_job.queue_adapter               = :que
    config.action_mailer.deliver_later_queue_name = :default
    config.action_mailbox.queues.incineration     = :default
    config.action_mailbox.queues.routing          = :default
    config.active_storage.queues.analysis         = :default
    config.active_storage.queues.purge            = :default

    config.google_cloud_bucket       = ENV.fetch('GOOGLE_CLOUD_BUCKET', '#GOOGLE_CLOUD_BUCKET_env_var_missing')
    config.dashboard_update_interval = ENV.fetch('DASHBOARD_UPDATE_INTERVAL', '0 0 */2 * *') # Midnight every two days

    # Notify
    config.notify_token       = ENV.fetch('GOVUK_NOTIFY_API_KEY', credentials.notify_api_key)
    # @note Nudge mail must only run once per day
    config.mail_job_interval  = ENV.fetch('MAIL_JOB_INTERVAL', '0 12 * * *') # Noon daily

    config.user_password = ENV.fetch('USER_PASSWORD', 'Str0ngPa$$w0rd12')
    config.bot_token = ENV['BOT_TOKEN']
    config.hotjar_site_id = ENV.fetch('HOTJAR_SITE_ID', '#HOTJAR_SITE_ID_env_var_missing')
    config.google_analytics_tracking_id = ENV.fetch('TRACKING_ID', '#TRACKING_ID_env_var_missing')

    # Devise
    config.unlock_in_minutes  = ENV.fetch('UNLOCK_IN_MINUTES', '120').to_i
    config.timeout_in_minutes = ENV.fetch('TIMEOUT_IN_MINUTES', '1440').to_i

    # Contentful
    config.contentful_space                   = ENV.fetch('CONTENTFUL_SPACE', credentials.dig(:contentful, :space))
    config.contentful_delivery_access_token   = ENV.fetch('CONTENTFUL_DELIVERY_TOKEN', credentials.dig(:contentful, :delivery_access_token))
    config.contentful_preview_access_token    = ENV.fetch('CONTENTFUL_PREVIEW_TOKEN', credentials.dig(:contentful, :preview_access_token))
    config.contentful_management_access_token = ENV.fetch('CONTENTFUL_MANAGEMENT_TOKEN', credentials.dig(:contentful, :management_access_token)) # TODO: use service account management token
    config.contentful_environment             = ENV.fetch('CONTENTFUL_ENVIRONMENT', credentials.dig(:contentful, :environment))

    # Gov One
    config.gov_one_base_uri    = credentials.dig(:gov_one, :base_uri)
    config.gov_one_private_key = credentials.dig(:gov_one, :private_key)
    config.gov_one_client_id   = credentials.dig(:gov_one, :client_id)

    # Sentry
    config.sentry_dsn = ENV.fetch('SENTRY_DSN', '#SENTRY_DSN_env_var_missing')

    # @return [Boolean]
    def live?
      ENV['ENVIRONMENT'].eql?('production')
    end

    # @see ContentfulRails.configuration.enable_preview_domain
    # @see ContentfulModel.use_preview_api
    #
    # @return [Boolean]
    def preview?
      Dry::Types['params.bool'][ENV.fetch('CONTENTFUL_PREVIEW', false)]
    end

    # @return [Boolean] Upload to CSV files to the dashboard
    def dashboard?
      Types::Params::Bool[ENV.fetch('DASHBOARD_UPDATE', true)]
    end

    # @return [Boolean]
    def debug?
      Types::Params::Bool[ENV.fetch('DEBUG', false)]
    end

    # @return [Boolean]
    def maintenance?
      Types::Params::Bool[ENV.fetch('MAINTENANCE', false)]
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

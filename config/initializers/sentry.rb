Sentry.init do |config|
  config.dsn = 'https://d89d03656e154896a2b733bb94f19eb9@o1115461.ingest.sentry.io/6274651'
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.enabled_environments = %w[production]

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 0.1
end

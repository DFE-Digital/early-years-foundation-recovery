locals {
  # Common tags to be assigned to resources
  common_tags = {
    "Environment"      = var.environment
    "Parent Business"  = "Children’s Care"
    "Portfolio"        = "Newly Onboarded"
    "Product"          = "EY Recovery"
    "Service"          = "Newly Onboarded"
    "Service Line"     = "Newly Onboarded"
    "Service Offering" = "EY Recovery"
  }

  # Web Application Configuration
  webapp_app_settings = {
    "ENVIRONMENT"                           = var.environment
    "DATABASE_URL"                          = var.webapp_database_url
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"   = "false"
    "BOT_TOKEN"                             = var.webapp_config_bot_token
    "USER_PASSWORD"                         = var.webapp_config_user_password
    "CONTENTFUL_ENVIRONMENT"                = var.webapp_config_contentful_environment
    "CONTENTFUL_PREVIEW"                    = var.webapp_config_contentful_preview
    "DOMAIN"                                = var.webapp_config_domain
    "EDITOR"                                = var.webapp_config_editor
    "FEEDBACK_URL"                          = var.webapp_config_feedback_url
    "GROVER_NO_SANDBOX"                     = var.webapp_config_grover_no_sandbox
    "MAINTENANCE"                           = var.environment == "development" ? "no" : "false"
    "NODE_ENV"                              = var.webapp_config_node_env
    "RAILS_ENV"                             = var.webapp_config_rails_env
    "RAILS_LOG_TO_STDOUT"                   = var.webapp_config_rails_log_to_stdout
    "RAILS_MASTER_KEY"                      = var.webapp_config_rails_master_key
    "RAILS_MAX_THREADS"                     = var.webapp_config_rails_max_threads
    "RAILS_SERVE_STATIC_FILES"              = var.webapp_config_rails_serve_static_files
    "SENTRY_DSN"                            = var.webapp_config_sentry_dsn
    "TRACKING_ID"                           = var.tracking_id
    "CLARITY_TRACKING_ID"                   = var.clarity_tracking_id
    "APPLICATION_INSIGHTS_CONNECTION_STRING" = module.monitor.insights_connection_string
    "WEB_CONCURRENCY"                       = var.webapp_config_web_concurrency
    "WEBSITES_CONTAINER_START_TIME_LIMIT"   = 720
  }

  webapp_slot_app_settings = {
    "ENVIRONMENT"                           = var.environment
    "DATABASE_URL"                          = var.webapp_slot_database_url
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"   = "false"
    "BOT_TOKEN"                             = var.webapp_config_bot_token
    "USER_PASSWORD"                         = var.webapp_config_user_password
    "CONTENTFUL_ENVIRONMENT"                = var.webapp_config_contentful_environment
    "CONTENTFUL_PREVIEW"                    = var.webapp_config_contentful_preview
    "DOMAIN"                                = var.webapp_config_domain
    "EDITOR"                                = var.webapp_config_editor
    "FEEDBACK_URL"                          = var.webapp_config_feedback_url
    "GROVER_NO_SANDBOX"                     = var.webapp_config_grover_no_sandbox
    "MAINTENANCE"                           = var.environment == "development" ? "no" : "false"
    "NODE_ENV"                              = var.webapp_config_node_env
    "RAILS_ENV"                             = var.webapp_config_rails_env
    "RAILS_LOG_TO_STDOUT"                   = var.webapp_config_rails_log_to_stdout
    "RAILS_MASTER_KEY"                      = var.webapp_config_rails_master_key
    "RAILS_MAX_THREADS"                     = var.webapp_config_rails_max_threads
    "RAILS_SERVE_STATIC_FILES"              = var.webapp_config_rails_serve_static_files
    "TRACKING_ID"                           = var.tracking_id
    "CLARITY_TRACKING_ID"                   = var.clarity_tracking_id
    "APPLICATION_INSIGHTS_CONNECTION_STRING" = module.monitor.insights_connection_string
    "WEB_CONCURRENCY"                       = var.webapp_config_web_concurrency
    "WEBSITES_CONTAINER_START_TIME_LIMIT"   = 720
  }

  # Background Worker Application Configuration, passed securely to container instances
  app_worker_environment_variables = {
    "DATABASE_URL"        = var.webapp_database_url
    "GCS_CREDENTIALS"     = var.gcs_credentials
    "GOOGLE_CLOUD_BUCKET" = var.webapp_config_google_cloud_bucket
    "RAILS_ENV"           = var.webapp_config_rails_env
    "RAILS_LOG_TO_STDOUT" = var.webapp_config_rails_log_to_stdout
    "RAILS_MASTER_KEY"    = var.webapp_config_rails_master_key
  }

  # Review Application Configuration
  reviewapp_app_settings = {
    "ENVIRONMENT"                           = var.environment
    "DATABASE_URL"                          = var.webapp_database_url
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"   = "false"
    "BOT_TOKEN"                             = var.webapp_config_bot_token
    "USER_PASSWORD"                         = var.webapp_config_user_password
    "CONTENTFUL_ENVIRONMENT"                = var.reviewapp_config_contentful_environment
    "CONTENTFUL_PREVIEW"                    = var.reviewapp_config_contentful_preview
    "DASHBOARD_UPDATE"                      = false
    "DOMAIN"                                = var.webapp_config_domain
    "EDITOR"                                = var.webapp_config_editor
    "FEEDBACK_URL"                          = var.webapp_config_feedback_url
    "GROVER_NO_SANDBOX"                     = var.webapp_config_grover_no_sandbox
    "NODE_ENV"                              = var.webapp_config_node_env
    "RAILS_ENV"                             = var.webapp_config_rails_env
    "RAILS_LOG_TO_STDOUT"                   = var.webapp_config_rails_log_to_stdout
    "RAILS_MASTER_KEY"                      = var.webapp_config_rails_master_key
    "RAILS_MAX_THREADS"                     = var.webapp_config_rails_max_threads
    "RAILS_SERVE_STATIC_FILES"              = var.webapp_config_rails_serve_static_files
    "APPLICATION_INSIGHTS_CONNECTION_STRING" = module.monitor.insights_connection_string
    "WEB_CONCURRENCY"                       = var.webapp_config_web_concurrency
    "WEBSITES_CONTAINER_START_TIME_LIMIT"   = 720
  }
}

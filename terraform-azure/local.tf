locals {
  # Common tags to be assigned resources
  common_tags = {
    "Environment"      = var.environment
    "Parent Business"  = "Children’s Care"
    "Portfolio"        = "Newly Onboarded"
    "Product"          = "EY Recovery"
    "Service"          = "Newly Onboarded"
    "Service Line"     = "Newly Onboarded"
    "Service Offering" = "EY Recovery"
  }

  # Web App Configuration
  webapp_app_settings = {
    "DATABASE_URL"                        = var.webapp_database_url
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "GOVUK_APP_DOMAIN"                    = "london.cloudapps.digital" #TODO: Remove this dependency post-migration to Azure
    "GOVUK_WEBSITE_ROOT"                  = "ey-recovery-dev"          #TODO: Remove this dependency post-migration to Azure
    "BOT_TOKEN"                           = var.webapp_config_bot_token
    "CONTENTFUL_ENVIRONMENT"              = var.webapp_config_contentful_environment
    "CONTENTFUL_PREVIEW"                  = var.webapp_config_contentful_preview
    "DOMAIN"                              = var.webapp_config_domain
    "EDITOR"                              = var.webapp_config_editor
    "FEEDBACK_URL"                        = var.webapp_config_feedback_url
    "GROVER_NO_SANDBOX"                   = var.webapp_config_grover_no_sandbox
    "GOOGLE_CLOUD_BUCKET"                 = var.webapp_config_google_cloud_bucket
    "NODE_ENV"                            = var.webapp_config_node_env
    "RAILS_ENV"                           = var.webapp_config_rails_env
    "RAILS_LOG_TO_STDOUT"                 = var.webapp_config_rails_log_to_stdout
    "RAILS_MASTER_KEY"                    = var.webapp_config_rails_master_key
    "RAILS_MAX_THREADS"                   = var.webapp_config_rails_max_threads
    "RAILS_SERVE_STATIC_FILES"            = var.webapp_config_rails_serve_static_files
    "TRAINING_MODULES"                    = var.webapp_config_training_modules
    "WEB_CONCURRENCY"                     = var.webapp_config_web_concurrency
    "WEBSITES_CONTAINER_START_TIME_LIMIT" = 1800
  }
}
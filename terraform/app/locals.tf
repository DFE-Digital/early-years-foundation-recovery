# ------------------------------------------------------------------------------
locals {
  # Project Name (space prefix)
  service_name = "ey-recovery"

  # Load Rails application env vars
  # ./terraform/workspace-variables/app_config.yml
  app_config_file = file("${path.module}/../workspace-variables/${var.paas_app_config_file}")
  app_config      = yamldecode(local.app_config_file)[var.paas_app_environment]
  is_production   = local.app_config["RAILS_ENV"] == "production"

  cf_api_url = "https://api.london.cloud.service.gov.uk"

  # Combine workspace variables with GH secrets
  paas_app_env_values = merge(local.app_config, var.paas_app_env_secrets)
}

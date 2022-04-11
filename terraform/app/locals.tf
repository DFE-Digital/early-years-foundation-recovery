# ------------------------------------------------------------------------------
locals {
  # Project Name (space)
  service_name = "ey-recovery"
  cf_api_url   = "https://api.london.cloud.service.gov.uk"

  # "ey-recovery" or "ey-recovery-review-pr-52"
  app_hostname = var.paas_app_hostname != "" ? local.service_name : "${local.service_name}-${var.paas_app_hostname}"

  # TODO:
  # db_hostname =

  # Load Rails application env vars
  # ./terraform/workspace-variables/app_config.yml
  app_config_file = file("${path.module}/../workspace-variables/${var.paas_app_config_file}")
  app_config      = yamldecode(local.app_config_file)[var.paas_app_environment]

  # Combine workspace variables with GH secrets
  paas_app_env_values = merge(local.app_config, var.paas_app_env_secrets)

  # Boolean checks
  is_production = local.app_config["RAILS_ENV"] == "production"
  is_review     = var.paas_app_environment == "review"
}

# ------------------------------------------------------------------------------
locals {
  # Project Name
  service_name = "eyfs-recovery"

  # Load Rails application env vars
  # ./terraform/workspace-variables/app_config.yml
  app_config_file = file("${path.module}/../workspace-variables/${var.paas_app_config_file}")
  app_config      = yamldecode(local.app_config_file)[var.paas_app_environment]
  is_production   = local.app_config["RAILS_ENV"] == "production"

  cf_api_url = "https://api.london.cloud.service.gov.uk"

  #
  paas_app_env_values = merge(
    # local.paas_app_env_yml_values,
    local.app_config,
    # var.secret_paas_app_env_values # app secrets injected by GH actions
    var.paas_app_env_secrets # app secrets injected by GH actions
  )
}

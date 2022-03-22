# ------------------------------------------------------------------------------
locals {
  service_name = "eyfs-recovery"
  is_production = var.environment == "production"
  cf_api_url =  "https://api.london.cloud.service.gov.uk"

  paas_app_env_yml_values = yamldecode(file("${path.module}/../workspace-variables/${var.app_environment}_app_env.yml"))

  paas_app_env_values = merge(
    local.paas_app_env_yml_values,
    var.secret_paas_app_env_values
  )
}

# ------------------------------------------------------------------------------
locals {
  # Project Name (cloud foundry space)
  service_name = "ey-recovery"
  cf_api_url   = "https://api.london.cloud.service.gov.uk"

  # Append a custom hostname on to the service name to create the web app domain
  #
  # - ey-recovery
  # - ey-recovery-staging
  # - ey-recovery-pr-52
  #
  app_hostname = var.paas_app_hostname != "" ? "${local.service_name}-${var.paas_app_hostname}" : local.service_name

  app_config_file = file("${path.module}/../workspace-variables/${var.paas_app_config_file}")
  app_config      = yamldecode(local.app_config_file)[var.paas_app_environment]

  enable_worker = var.paas_app_environment == "content" ? false : true

  # Combine environment variables in order of precedence
  app_envs = merge(
    local.app_config,           # Workspace variables
    var.paas_app_env_secrets,   # GitHub Secrets
    var.paas_app_envs           # Workflow Envs
  )
}

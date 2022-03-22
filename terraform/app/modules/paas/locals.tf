# ------------------------------------------------------------------------------
locals {

  app_env_domain  = {
    "DOMAIN"              = "eyfs-${var.environment}.london.cloudapps.digital"
    "GOVUK_APP_DOMAIN"    = "eyfs-${var.environment}.london.cloudapps.digital"
    "GOVUK_WEBSITE_ROOT"  = "eyfs-${var.environment}.london.cloudapps.digital"
  }

  app_environment = merge(
    local.app_env_domain,

    # Because of merge order, if present, the value of DOMAIN in .tfvars will overwrite app_env_domain
    var.app_env_values
  )

  app_cloudfoundry_service_instances = [
    cloudfoundry_service_instance.postgres_instance.id,
  ]

  app_service_bindings = concat(
    local.app_cloudfoundry_service_instances,
  )

  postgres_service_name    = "${var.service_name}-postgres-${var.environment}"
  web_app_name             = "${var.service_name}-${var.environment}"
}

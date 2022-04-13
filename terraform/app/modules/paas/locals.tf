# ------------------------------------------------------------------------------
locals {

  # TODO: calculate domain using "is_review" etc
  # DOMAIN values
  # These should not be in the module and are app specific
  app_env_values = {
    "DOMAIN"             = "${var.web_app_name}.london.cloudapps.digital"
    "GOVUK_APP_DOMAIN"   = "${var.web_app_name}.london.cloudapps.digital"
    "GOVUK_WEBSITE_ROOT" = "${var.web_app_name}.london.cloudapps.digital"
  }

  # Combine module with main module variables which take precedence
  app_environment = merge(local.app_env_values, var.app_env_values)

  app_cf_service_instances = [cloudfoundry_service_instance.postgres_instance.id]
  app_service_bindings     = concat(local.app_cf_service_instances)

  # example: ey-recovery-db-review
  db_service_name = "${var.service_name}-db-${var.app_environment}"
}

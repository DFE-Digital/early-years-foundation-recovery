# ------------------------------------------------------------------------------
locals {

  # @example: ey-recovery
  # web_app_name = var.service_name

  # @example: ey-recovery-review
  # web_app_name = "${var.service_name}-${var.app_environment}"

  # @example: ey-recovery-review-pr-52
  web_app_name = "${var.service_name}-${var.app_hostname}"

  # HOSTNAME only
  app_env_domain = {
    "DOMAIN" = "${local.web_app_name}.london.cloudapps.digital"

    # plek
    # "GOVUK_APP_DOMAIN"   = "eyfs-${var.environment}.london.cloudapps.digital"
    # "GOVUK_WEBSITE_ROOT" = "eyfs-${var.environment}.london.cloudapps.digital"
  }

  # NB: because of merge order, if present,
  # the value of DOMAIN in .tfvars will overwrite app_env_domain
  app_environment = merge(local.app_env_domain, var.app_env_values)

  app_cf_service_instances = [cloudfoundry_service_instance.postgres_instance.id]
  app_service_bindings     = concat(local.app_cf_service_instances)

  # prematurely assumed the db is postgres
  postgres_service_name = "${var.service_name}-postgres-${var.app_environment}"
  # app_db_name = "${var.service_name}-db-${var.app_environment}"
}

# ------------------------------------------------------------------------------
locals {


  app_env_domain = {
    "DOMAIN" = "eyfs-${var.app_environment}.london.cloudapps.digital"
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

  web_app_name = "${var.service_name}-${var.app_environment}"
  # app_web_name = "${var.service_name}-${var.app_environment}"
}




# locals {
#   web_app_name          = "find-${var.app_environment}"
#   web_app_start_command = "bundle exec rails server -b 0.0.0.0"
#   logging_service_name  = "find-logit-${var.app_environment}"
#   service_gov_uk_host_names = {
#     qa      = ["qa"]
#     staging = ["staging"]
#     sandbox = ["sandbox"]
#     prod    = ["www", "www2"]
#   }

#   web_app_service_gov_uk_route_ids = [
#     for r in cloudfoundry_route.web_app_service_gov_uk_route : r.id
#   ]

#   web_app_routes = concat(
#     local.web_app_service_gov_uk_route_ids, [cloudfoundry_route.web_app_cloudapps_digital_route.id]
#   )
# }

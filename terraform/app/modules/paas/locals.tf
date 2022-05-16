# ------------------------------------------------------------------------------
locals {
  app_cf_service_instances = [cloudfoundry_service_instance.postgres_instance.id]
  app_service_bindings     = concat(local.app_cf_service_instances)

  # ey-recovery-db-production
  # ey-recovery-db-staging
  # ey-recovery-db-pr-123
  db_service_name = "${var.service_name}-db-${var.web_app_name}"

  db_json_params = jsonencode(var.postgres_json_params)
}

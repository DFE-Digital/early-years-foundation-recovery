# ------------------------------------------------------------------------------
locals {
  app_cf_service_instances = [cloudfoundry_service_instance.postgres_instance.id]
  app_service_bindings     = concat(local.app_cf_service_instances)

  # ey-recovery-db-production
  # ey-recovery-db-staging
  # ey-recovery-db-content
  db_service_name = "${var.service_name}-db-${var.app_environment}"
}

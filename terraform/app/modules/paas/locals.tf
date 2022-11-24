# ------------------------------------------------------------------------------
locals {
  app_cf_service_instances = [
    cloudfoundry_service_instance.postgres_instance.id,
    cloudfoundry_service_instance.s3.id,
  ]

  app_service_bindings     = concat(local.app_cf_service_instances)
  db_service_name          = "${var.web_app_name}-db"
  db_json_params           = jsonencode(var.postgres_json_params)


  s3_params = {
    bucket = var.s3_bucket
    acl    = "private"
  }
  s3_json_params = jsonencode(local.s3_params)

}

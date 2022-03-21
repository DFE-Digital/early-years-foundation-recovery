# ------------------------------------------------------------------------------
module paas {
  source = "./modules/paas"

  environment                       = var.environment

  service_name                      = local.service_name
  app_env_values                    = local.paas_app_env_values

  space_name                        = var.paas_space_name

  app_docker_image                  = var.paas_app_docker_image
  app_start_timeout                 = var.paas_app_start_timeout
  app_stopped                       = var.paas_app_stopped

  postgres_create_timeout           = var.paas_postgres_create_timeout
  postgres_service_plan             = var.paas_postgres_service_plan

  web_app_deployment_strategy       = var.paas_web_app_deployment_strategy
  web_app_instances                 = var.paas_web_app_instances
  web_app_memory                    = var.paas_web_app_memory
  web_app_start_command             = var.paas_web_app_start_command

  # cms_app_start_command             = var.paas_cms_app_start_command
}

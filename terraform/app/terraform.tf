# ------------------------------------------------------------------------------
terraform {
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = ">= 0.14.5"
    }
  }

  backend "s3" {
    key     = "terraform.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}

module "paas" {
  source                  = "./modules/paas"
  cf_api_url              = local.cf_api_url          #
  service_name            = local.service_name        # eyfs-recovery
  app_environment         = var.paas_app_environment  # Terraform Workspace: review/prod/qa
  app_env_values          = local.paas_app_env_values # hash of YAML and GH secrets
  cf_user                 = var.paas_cf_user
  cf_password             = var.paas_cf_password
  cf_sso_passcode         = var.paas_cf_sso_passcode
  cf_space_name           = var.paas_cf_space_name
  app_docker_image        = var.paas_app_docker_image
  postgres_create_timeout = var.paas_postgres_create_timeout
  postgres_service_plan   = var.paas_postgres_service_plan
  web_app_instances       = var.paas_web_app_instances
  web_app_memory          = var.paas_web_app_memory
  web_app_start_command   = var.paas_web_app_start_command

}


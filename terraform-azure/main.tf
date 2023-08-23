provider "azurerm" {
  use_oidc = true

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_name_prefix}-rg"
  location = var.azure_region

  tags = local.common_tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create Network resources
module "network" {
  source = "./terraform-azure-network"

  environment                               = var.environment
  location                                  = var.azure_region
  resource_group                            = azurerm_resource_group.rg.name
  resource_name_prefix                      = var.resource_name_prefix
  domain_name_label                         = var.webapp_name
  kv_certificate_authority_label            = "GlobalSignCA"
  kv_certificate_authority_name             = "GlobalSign"
  kv_certificate_authority_username         = var.kv_certificate_authority_username
  kv_certificate_authority_password         = var.kv_certificate_authority_password
  kv_certificate_authority_admin_email      = var.kv_certificate_authority_admin_email
  kv_certificate_authority_admin_first_name = var.kv_certificate_authority_admin_first_name
  kv_certificate_authority_admin_last_name  = var.kv_certificate_authority_admin_last_name
  kv_certificate_authority_admin_phone_no   = var.kv_certificate_authority_admin_phone_no
  kv_certificate_label                      = var.kv_certificate_label
  kv_certificate_subject                    = var.kv_certificate_subject
}

# Create Database resources
module "database" {
  source = "./terraform-azure-database"

  location                    = var.azure_region
  resource_group              = azurerm_resource_group.rg.name
  resource_name_prefix        = var.resource_name_prefix
  psqlfs_subnet_id            = module.network.psqlfs_subnet_id
  psqlfs_dns_zone_id          = module.network.psqlfs_dns_zone_id
  psqlfs_sku                  = var.psqlfs_sku
  psqlfs_storage              = var.psqlfs_storage
  psqlfs_username             = var.psqlfs_username
  psqlfs_password             = var.psqlfs_password
  psqlfs_geo_redundant_backup = var.psqlfs_geo_redundant_backup
  psqlfs_ha_enabled           = var.psqlfs_ha_enabled
  depends_on                  = [module.network]
}

# Create Web Application resources
module "webapp" {
  source = "./terraform-azure-web"

  environment                              = var.environment
  asp_sku                                  = var.asp_sku
  webapp_worker_count                      = var.webapp_worker_count
  location                                 = var.azure_region
  resource_group                           = azurerm_resource_group.rg.name
  resource_name_prefix                     = var.resource_name_prefix
  webapp_subnet_id                         = module.network.webapp_subnet_id
  webapp_name                              = var.webapp_name
  webapp_app_settings                      = local.webapp_app_settings
  webapp_docker_image                      = var.webapp_docker_image
  webapp_docker_image_tag                  = var.webapp_docker_image_tag
  webapp_docker_registry_url               = var.webapp_docker_registry_url
  webapp_health_check_path                 = "/health"
  webapp_health_check_eviction_time_in_min = 10
  webapp_custom_domain_name                = var.webapp_custom_domain_name
  webapp_custom_domain_cert_secret_label   = var.kv_certificate_label
  kv_id                                    = module.network.kv_id
  kv_cert_secret_id                        = module.network.kv_cert_secret_id
  depends_on                               = [module.network, module.database]
}

## Create Background Worker Application resources
module "app-worker" {
  source = "./terraform-azure-app"

  location                         = var.azure_region
  resource_group                   = azurerm_resource_group.rg.name
  resource_name_prefix             = "${var.resource_name_prefix}-worker"
  app_worker_subnet_id             = module.network.app_worker_subnet_id
  app_worker_name                  = var.workerapp_name
  container_name                   = var.workerapp_name
  app_worker_environment_variables = local.app_worker_environment_variables
  app_worker_docker_image          = var.webapp_docker_image
  app_worker_docker_image_tag      = var.webapp_docker_image_tag
  app_worker_docker_registry       = "ghcr.io"
  app_worker_startup_command       = ["bundle", "exec", "que"]
  depends_on                       = [module.network, module.database]
}

# Create Review Application resources
module "review-apps" {
  source = "./terraform-azure-review"
  # Review Applications are only deployed to the Development subscription
  count = var.environment == "development" ? 1 : 0

  asp_sku                                  = "P1v2"
  location                                 = var.azure_region
  resource_group                           = azurerm_resource_group.rg.name
  resource_name_prefix                     = "${var.resource_name_prefix}-review"
  webapp_vnet_name                         = module.network.vnet_name
  webapp_name                              = var.reviewapp_name
  webapp_app_settings                      = local.reviewapp_app_settings
  webapp_docker_image                      = var.webapp_docker_image
  webapp_docker_image_tag                  = var.webapp_docker_image_tag
  webapp_docker_registry_url               = var.webapp_docker_registry_url
  webapp_health_check_path                 = "/health"
  webapp_health_check_eviction_time_in_min = 10
  depends_on                               = [module.network, module.database]
}
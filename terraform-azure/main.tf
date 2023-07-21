provider "azurerm" {
  use_oidc = true

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
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

  location             = var.azure_region
  resource_group       = azurerm_resource_group.rg.name
  resource_name_prefix = var.resource_name_prefix
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
  depends_on                  = [module.network]
}

# Create Web Application resources
module "webapp" {
  source = "./terraform-azure-web"

  asp_sku                                  = var.asp_sku
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
  depends_on                               = [module.network, module.database]
}

## Create Background Worker Application resources
module "app-worker" {
  source = "./terraform-azure-app"

  location                         = var.azure_region
  resource_group                   = azurerm_resource_group.rg.name
  resource_name_prefix             = "${var.resource_name_prefix}-worker"
  app_worker_subnet_id             = module.network.app_worker_subnet_id
  app_worker_name                  = "${var.webapp_name}-worker"
  container_name                   = "eyrecovery-worker"
  app_worker_environment_variables = local.webapp_app_settings
  app_worker_docker_image          = var.webapp_docker_image
  app_worker_docker_image_tag      = var.webapp_docker_image_tag
  app_worker_docker_registry       = "ghcr.io"
  app_worker_startup_command       = ["bundle", "exec", "que"]
  depends_on                       = [module.network, module.database]
}
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

  asp_sku                         = var.asp_sku
  location                        = var.azure_region
  resource_group                  = azurerm_resource_group.rg.name
  resource_name_prefix            = var.resource_name_prefix
  webapp_subnet_id                = module.network.webapp_subnet_id
  webapp_name                     = var.webapp_name
  webapp_app_settings             = local.webapp_app_settings
  webapp_docker_image         = var.webapp_docker_image
  webapp_docker_image_tag         = var.webapp_docker_image_tag
  webapp_docker_registry_url      = var.webapp_docker_registry_url
  webapp_docker_registry_username = var.webapp_docker_registry_username
  webapp_docker_registry_password = var.webapp_docker_registry_password
  webapp_health_check_path        = "/health"
  depends_on                      = [module.network, module.database]
}

# Create Web Application Background Worker resources
module "webapp-worker" {
  source = "./terraform-azure-web"

  asp_sku                         = var.asp_sku
  location                        = var.azure_region
  resource_group                  = azurerm_resource_group.rg.name
  resource_name_prefix            = "${var.resource_name_prefix}-worker"
  webapp_subnet_id                = module.network.webapp_worker_subnet_id
  webapp_name                     = "${var.webapp_name}-worker"
  webapp_public_access            = false
  webapp_app_settings             = merge({ "APP_COMMAND_LINE" = "bundle exec que" }, local.webapp_app_settings)
  webapp_docker_image         = var.webapp_docker_image
  webapp_docker_image_tag         = var.webapp_docker_image_tag
  webapp_docker_registry_url      = var.webapp_docker_registry_url
  webapp_docker_registry_username = var.webapp_docker_registry_username
  webapp_docker_registry_password = var.webapp_docker_registry_password
  webapp_health_check_path        = "/health"
  depends_on                      = [module.network, module.database]
}
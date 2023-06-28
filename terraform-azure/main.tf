provider "azurerm" {
  use_oidc = true

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "Environment"      = var.environment
    "Parent Business"  = "Children’s Care"
    "Portfolio"        = "Newly Onboarded"
    "Product"          = "EY Recovery"
    "Service"          = "Newly Onboarded"
    "Service Line"     = "Newly Onboarded"
    "Service Offering" = "EY Recovery"
  }
}

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_name_prefix}-rg"
  location = var.azure_region

  tags = merge(local.common_tags, {
  })

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
# TODO: App configuration settings (env variables) below should be a map/dictionary
module "webapp" {
  source = "./terraform-azure-web"

  asp_sku                         = var.asp_sku
  location                        = var.azure_region
  resource_group                  = azurerm_resource_group.rg.name
  resource_name_prefix            = var.resource_name_prefix
  webapp_subnet_id                = module.network.webapp_subnet_id
  webapp_name                     = "eyrecovery-dev"
  webapp_database_url             = var.webapp_database_url
  webapp_docker_registry_url      = var.webapp_docker_registry_url
  webapp_docker_registry_username = var.webapp_docker_registry_username
  webapp_docker_registry_password = var.webapp_docker_registry_password
  webapp_docker_image_url         = var.webapp_docker_image_url
  webapp_docker_image_tag         = var.webapp_docker_image_tag
  webapp_startup_command          = "bundle exec rails db:prepare assets:precompile sitemap:refresh:no_ping && bundle exec rails server -b 0.0.0.0"
  depends_on                      = [module.network, module.database]
}
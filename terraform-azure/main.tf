provider "azurerm" {
  use_oidc = true
  features {}
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "Environment"      = var.default_environment
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
  location = var.default_azure_region

  tags = merge(local.common_tags, {
  })
}

# Create Network resources
module "network" {
  source = "./terraform-azure-network"

  location             = var.default_azure_region
  resource_group       = azurerm_resource_group.rg.name
  resource_name_prefix = var.resource_name_prefix
}

# Create Database resources
module "database" {
  source = "./terraform-azure-database"

  location                    = var.default_azure_region
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
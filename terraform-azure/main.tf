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

# Create Network related resources
module "network" {
  source = "./terraform-azure-network"

  location             = var.default_azure_region
  resource_group       = azurerm_resource_group.rg.name
  resource_name_prefix = var.resource_name_prefix
}

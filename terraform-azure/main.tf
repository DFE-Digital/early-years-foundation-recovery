provider "azurerm" {
  features {}
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "Environment"      = "dev"
    "Parent Business"  = "Children’s Care"
    "Portfolio"        = "Newly Onboarded"
    "Product"          = "EY Recovery"
    "Service"          = "Newly Onboarded"
    "Service Line"     = "Newly Onboarded"
    "Service Offering" = "EY Recovery"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = "westeurope"

  tags = merge(local.common_tags, {
    "Location" = "West Europe"
  })
}

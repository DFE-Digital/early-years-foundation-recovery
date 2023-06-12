# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

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

# Create Remote State Storage
resource "azurerm_resource_group" "tfstate" {
  name     = "${var.resource_name_prefix}-tfstate-rg"
  location = var.default_azure_region

  tags = merge(local.common_tags, {
    "Region" = var.default_azure_region
  })
}

resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "eyrecoverytfstate${random_string.resource_code.result}st"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = var.default_azure_region
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false

  tags = merge(local.common_tags, {
    "Region" = var.default_azure_region
  })
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "${var.resource_name_prefix}-tfstate-stc"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.7.0"
    }
  }

  required_version = ">= 1.1.0"

  backend "azurerm" {
    resource_group_name  = "s187d01-eyrecovery-tfstate-rg"
    storage_account_name = "eyrecoverytfstatekoi8mst"
    container_name       = "s187d01-eyrecovery-tfstate-stc"
    key                  = "terraform.tfstate"
    use_oidc             = true
    subscription_id      = var.subscription_id
    tenant_id            = var.tenant_id
  }
}

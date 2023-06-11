# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"

  backend "azurerm" {
    resource_group_name  = "s187d01-eyrecovery-tfstate-rg"
    storage_account_name = "eyrecoverytfstatekoi8mst"
    container_name       = "s187d01-eyrecovery-tfstate-stc"
    key                  = "terraform.tfstate"
  }
}
# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.67.0"
    }
  }

  required_version = ">= 1.12.2, < 2.0.0"

  backend "azurerm" {
    use_oidc = true
  }
}
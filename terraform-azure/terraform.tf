# # Configure the Azure provider
# terraform {
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "= 3.71.0"
#     }
#   }


#   required_version = ">= 1.5.0"

#   #backend "azurerm" {
#   #use_oidc = true
#   #}
# }



##new as suggeted

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

# Second AzureRM provider configuration
# Used only for the new RBAC Key Vault resources
provider "azurerm" {
  alias = "keyvault_rbac"

  features {}
}
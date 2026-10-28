terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.71.0"

      configuration_aliases = [
        azurerm.keyvault_rbac
      ]
    }
  }
}

# Create Key Vault with rbac

resource "azurerm_key_vault" "rbackv" {
  provider            = azurerm.keyvault_rbac
  location            = var.location
  name                = "${var.resource_name_prefix}-rbkv"
  resource_group_name = var.resource_group
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.az_config.tenant_id

  purge_protection_enabled = true

  enable_rbac_authorization     = true
  public_network_access_enabled = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = {
    "Environment" = var.environment
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_endpoint" "rbackv" {
  name                = "${var.resource_name_prefix}-rbkv-pe"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = azurerm_subnet.keyvault_private_endpoint_snet.id

  private_service_connection {
    name                           = "${var.resource_name_prefix}-rbkv-psc"
    private_connection_resource_id = azurerm_key_vault.rbackv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.keyvault_private_dns.id]
  }
}

# RBAC: allow app identity to read secrets (use object_id, not client_id)

data "azurerm_role_definition" "kv_secrets_user" {
  name  = "Key Vault Secrets User"
  scope = azurerm_key_vault.rbackv.id
}

data "azurerm_role_definition" "kv_secrets_officer" {
  name  = "Key Vault Secrets Officer"
  scope = azurerm_key_vault.rbackv.id
}


data "azurerm_role_definition" "kv_admin" {
  name  = "Key Vault Administrator"
  scope = azurerm_key_vault.rbackv.id
}



# Role assignments are deferred until the principals are available.

# resource "azurerm_role_assignment" "kv_user1" {
#   provider = azurerm.keyvault_rbac
#
#   scope                = azurerm_key_vault.rbackv.id
#   role_definition_name = "Key Vault Secrets User"
#   principal_id         = var.kv_user_object_id
# }
#
# resource "azurerm_role_assignment" "kv_officer" {
#   provider = azurerm.keyvault_rbac
#
#   scope                = azurerm_key_vault.rbackv.id
#   role_definition_name = "Key Vault Certificates Officer"
#   principal_id         = var.kv_officer_object_id
# }
#
# resource "azurerm_role_assignment" "kv_administrator" {
#   provider = azurerm.keyvault_rbac
#
#   scope                = azurerm_key_vault.rbackv.id
#   role_definition_name = "Key Vault Administrator"
#   principal_id         = var.kv_administrator_object_id
# }
#
#
# resource "azurerm_role_assignment" "kv_admin_sp" {
#   provider = azurerm.keyvault_rbac
#
#   scope                = azurerm_key_vault.rbackv.id
#   role_definition_name = "Key Vault Administrator"
#   principal_id         = var.kv_admin_sp_object_id
# }

# resource "azurerm_role_assignment" "kv_user" {
#   scope              = azurerm_key_vault.rbackv.id
#   role_definition_id = data.azurerm_role_definition.kv_secrets_user.role_definition_id
#   principal_id       = azurerm_user_assigned_identity.cl-identity-reader.principal_id
#   principal_type     = "ServicePrincipal"
# }

# resource "azurerm_role_assignment" "kv_officer" {
#   scope              = azurerm_key_vault.rbackv.id
#   role_definition_id = data.azurerm_role_definition.kv_secrets_officer.role_definition_id
#   principal_id       = azurerm_user_assigned_identity.cl-identity-administrator.principal_id
#   principal_type     = "ServicePrincipal"
# }

# resource "azurerm_role_assignment" "kv_administrator" {
#   scope              = azurerm_key_vault.rbackv.id
#   role_definition_id = data.azurerm_role_definition.kv_admin.role_definition_id
#   principal_id       = azurerm_user_assigned_identity.cl-identity-administrator.principal_id
#   principal_type     = "ServicePrincipal"
# }

# resource "azurerm_role_assignment" "kv_admin_sp" {
#   scope              = azurerm_key_vault.rbackv.id
#   role_definition_id = data.azurerm_role_definition.kv_admin.role_definition_id
#   principal_id       = data.azurerm_client_config.az_config.object_id
#   principal_type     = "ServicePrincipal"
# }


#Identities
resource "azurerm_user_assigned_identity" "cl-identity-reader" {
  name                = "${var.resource_name_prefix}mid-uks-cl-r"
  location            = var.location
  resource_group_name = var.resource_group

  #tags = local.common_tags
}

resource "azurerm_user_assigned_identity" "cl-identity-administrator" {
  name                = "${var.resource_name_prefix}mid-uks-cl-a"
  location            = var.location
  resource_group_name = var.resource_group

  # tags = local.common_tags
}

# Secrets

# resource "azurerm_key_vault_secret" "contentful_delivery_api_key_rbac" {
#   name         = "ContentfulOptions--DeliveryApiKey"
#   value        = var.contentful_delivery_api_key
#   key_vault_id = azurerm_key_vault.rbackv.id
# }

# resource "azurerm_key_vault_secret" "contentful_preview_api_key_rbac" {
#   name         = "ContentfulOptions--PreviewApiKey"
#   value        = var.contentful_preview_api_key
#   key_vault_id = azurerm_key_vault.rbackv.id
# }

# resource "azurerm_key_vault_secret" "contentful_management_api_key_rbac" {
#   name         = "ContentfulOptions--ManagementApiKey"
#   value        = var.contentful_management_api_key
#   key_vault_id = azurerm_key_vault.rbackv.id
# }

# resource "azurerm_key_vault_secret" "contentful_space_id_rbac" {
#   name         = "ContentfulOptions--SpaceId"
#   value        = var.contentful_space_id
#   key_vault_id = azurerm_key_vault.rbackv.id
# }

# resource "azurerm_key_vault_secret" "govuk_notify_api_key_rbac" {
#   name         = "Notifications--ApiKey"
#   value        = var.govuk_notify_api_key
#   key_vault_id = azurerm_key_vault.rbackv.id
# }

# resource "azurerm_key_vault_secret" "download_endpoint_secret_rbac" {
#   name         = "Download--AuthSecret"
#   value        = var.download_endpoint_secret
#   key_vault_id = azurerm_key_vault.rbackv.id
# }
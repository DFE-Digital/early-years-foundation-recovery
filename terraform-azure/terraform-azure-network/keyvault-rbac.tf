terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.67.0"

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

  soft_delete_retention_days = 90
  purge_protection_enabled   = true

  enable_rbac_authorization     = true
  public_network_access_enabled = false

  network_acls {
    default_action = "Deny"
    bypass         = "None"
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

  lifecycle {
    ignore_changes = [tags]
  }
}

# RBAC: allow app identity to read secrets (use object_id, not client_id)

resource "azurerm_role_assignment" "kv_user" {
  provider = azurerm.keyvault_rbac

  scope                            = azurerm_key_vault.rbackv.id
  role_definition_name             = "Key Vault Secrets User"
  principal_id                     = azurerm_user_assigned_identity.cl-identity-reader.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "kv_officer" {
  provider = azurerm.keyvault_rbac

  scope                            = azurerm_key_vault.rbackv.id
  role_definition_name             = "Key Vault Secrets Officer"
  principal_id                     = azurerm_user_assigned_identity.cl-identity-administrator.principal_id
  skip_service_principal_aad_check = true
}


# The reader identity is attached to runtime workloads; keep the administrator identity separate.
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
# Create Key Vault
data "azurerm_client_config" "az_config" {}

resource "azurerm_key_vault" "kv" {
  # Key Vault only deployed to the Test and Production subscription
  count = var.environment != "development" ? 1 : 0

  name                        = "${var.resource_name_prefix}-kv"
  resource_group_name         = var.resource_group
  location                    = var.location
  tenant_id                   = data.azurerm_client_config.az_config.tenant_id
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_key_vault_access_policy" "kv_ap" {
  # Key Vault only deployed to the Test and Production subscription
  count = var.environment != "development" ? 1 : 0

  key_vault_id = azurerm_key_vault.kv[0].id
  tenant_id    = data.azurerm_client_config.az_config.tenant_id
  object_id    = data.azurerm_client_config.az_config.object_id

  certificate_permissions = [
    "Create",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "SetIssuers",
    "Update"
  ]
}

resource "azurerm_key_vault_certificate_issuer" "kv_ca" {
  # Key Vault only deployed to the Test and Production subscription
  count = var.environment != "development" ? 1 : 0

  name          = var.kv_certificate_authority_label
  key_vault_id  = azurerm_key_vault.kv[0].id
  provider_name = var.kv_certificate_authority_name
  account_id    = var.kv_certificate_authority_username
  password      = var.kv_certificate_authority_password

  admin {
    email_address = var.kv_certificate_authority_admin_email
    first_name    = var.kv_certificate_authority_admin_first_name
    last_name     = var.kv_certificate_authority_admin_last_name
    phone         = var.kv_certificate_authority_admin_phone_no
  }
}

resource "azurerm_key_vault_certificate" "kv_cert" {
  # Key Vault only deployed to the Test and Production subscription
  count = var.environment != "development" ? 1 : 0

  name         = var.kv_certificate_label
  key_vault_id = azurerm_key_vault.kv[0].id

  certificate_policy {
    issuer_parameters {
      name = var.kv_certificate_authority_label
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = ["1.3.6.1.5.5.7.3.1", "1.3.6.1.5.5.7.3.2"]
      key_usage          = ["digitalSignature", "keyEncipherment"]
      subject            = var.kv_certificate_subject
      validity_in_months = 12
    }
  }
}
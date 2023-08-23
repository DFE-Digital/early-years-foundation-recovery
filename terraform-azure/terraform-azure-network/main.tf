# Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_name_prefix}-vnet"
  location            = var.location
  resource_group_name = var.resource_group
  address_space       = ["172.1.0.0/16"]

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create Subnet for Database Server
resource "azurerm_subnet" "psqlfs_snet" {
  name                 = "${var.resource_name_prefix}-psqlfs-snet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group
  address_prefixes     = ["172.1.0.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "${var.resource_name_prefix}-psqlfs-dn"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }

  #checkov:skip=CKV2_AZURE_31:NSG not required
}

# Create a Private DNS Zone for Database Server
resource "azurerm_private_dns_zone" "psqlfs_dnsz" {
  name                = "${var.resource_name_prefix}.postgres.database.azure.com"
  resource_group_name = var.resource_group

  lifecycle {
    ignore_changes = [tags]
  }
}

# Link the Private DNS Zone to the Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "psqlfs_dnsz_vnetl" {
  name                  = "${var.resource_name_prefix}-psqlfs-dnsz-vnetl"
  private_dns_zone_name = azurerm_private_dns_zone.psqlfs_dnsz.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = var.resource_group

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create Subnet for Web App
resource "azurerm_subnet" "webapp_snet" {
  name                 = "${var.resource_name_prefix}-webapp-snet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group
  address_prefixes     = ["172.1.1.0/26"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]

  delegation {
    name = "${var.resource_name_prefix}-webapp-dn"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

  #checkov:skip=CKV2_AZURE_31:NSG not required
}

# Create Subnet for Background Worker App
resource "azurerm_subnet" "app_worker_snet" {
  name                 = "${var.resource_name_prefix}-app-worker-snet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group
  address_prefixes     = ["172.1.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "${var.resource_name_prefix}-app-worker-dn"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

  #checkov:skip=CKV2_AZURE_31:NSG not required
}

# Create PIP for App Gateway
resource "azurerm_public_ip" "agw_pip" {
  # Application Gateway is not deployed to the Development subscription
  count = var.environment != "development" ? 1 : 0

  name                    = "${var.resource_name_prefix}-agw-pip"
  resource_group_name     = var.resource_group
  location                = var.location
  allocation_method       = "Static"
  ip_version              = "IPv4"
  sku                     = "Standard"
  sku_tier                = "Regional"
  zones                   = []
  idle_timeout_in_minutes = 4

  lifecycle {
    ignore_changes = [tags]
  }
}

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

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.az_config.tenant_id
    object_id = data.azurerm_client_config.az_config.object_id

    certificate_permissions = [
      "Create",
      "Delete",
      "DeleteIssuers",
      "Get",
      "GetIssuers",
      "Import",
      "List",
      "ListIssuers",
      "ManageContacts",
      "ManageIssuers",
      "Purge",
      "SetIssuers",
      "Update"
    ]

    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey"
    ]

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set"
    ]
  }

  lifecycle {
    ignore_changes = [tags]
  }
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
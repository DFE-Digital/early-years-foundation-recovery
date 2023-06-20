# Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_name_prefix}-vnet"
  location            = var.location
  resource_group_name = var.resource_group
  address_space       = ["172.1.0.0/16"]
}

# Create Subnet for Database
resource "azurerm_subnet" "db_snet" {
  name                 = "${var.resource_name_prefix}-snet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group
  address_prefixes     = ["172.1.0.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "${var.resource_name_prefix}-db-dn"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Create a Private DNS Zone for Database
resource "azurerm_private_dns_zone" "db_dnsz" {
  name                = "${var.resource_name_prefix}.postgres.database.azure.com"
  resource_group_name = var.resource_group
}

# Link the Private DNS Zone to the Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "db_dnsz_vnetl" {
  name                  = "${var.resource_name_prefix}-db-dnsz-vnetl"
  private_dns_zone_name = azurerm_private_dns_zone.db_dnsz.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = var.resource_group
}
locals {
  redis_enabled = contains(["staging", "production"], var.environment)
  redis_app_settings = local.redis_enabled ? {
    REDIS_URL       = "rediss://:${urlencode(azurerm_managed_redis.cache[0].default_database[0].primary_access_key)}@${azurerm_managed_redis.cache[0].hostname}:${azurerm_managed_redis.cache[0].default_database[0].port}/0"
    CACHE_NAMESPACE = "${var.resource_name_prefix}:live"
  } : {}
}

resource "azurerm_managed_redis" "cache" {
  count = local.redis_enabled ? 1 : 0

  name                      = "${var.resource_name_prefix}-redis"
  location                  = var.azure_region
  resource_group_name       = azurerm_resource_group.rg.name
  sku_name                  = var.redis_sku_name
  high_availability_enabled = var.environment == "production"
  public_network_access     = "Disabled"
  tags                      = local.common_tags

  default_database {
    access_keys_authentication_enabled = true
    client_protocol                    = "Encrypted"
    clustering_policy                  = "EnterpriseCluster"
    eviction_policy                    = "AllKeysLRU"
  }
}

resource "azurerm_subnet" "redis" {
  count = local.redis_enabled ? 1 : 0

  name                              = "${var.resource_name_prefix}-redis-snet"
  resource_group_name               = azurerm_resource_group.rg.name
  virtual_network_name              = module.network.vnet_name
  address_prefixes                  = ["172.1.4.0/28"]
  private_endpoint_network_policies = "NetworkSecurityGroupEnabled"
}

resource "azurerm_network_security_group" "redis" {
  count = local.redis_enabled ? 1 : 0

  name                = "${var.resource_name_prefix}-redis-nsg"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  security_rule {
    name                       = "AllowRedisFromApplications"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "10000"
    source_address_prefixes    = ["172.1.1.0/26", "172.1.2.0/24"]
    destination_address_prefix = "172.1.4.0/28"
  }

  security_rule {
    name                       = "DenyOtherInbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "redis" {
  count = local.redis_enabled ? 1 : 0

  subnet_id                 = azurerm_subnet.redis[0].id
  network_security_group_id = azurerm_network_security_group.redis[0].id
}

resource "azurerm_private_dns_zone" "redis" {
  count = local.redis_enabled ? 1 : 0

  name                = "privatelink.redis.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  count = local.redis_enabled ? 1 : 0

  name                  = "${var.resource_name_prefix}-redis-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.redis[0].name
  virtual_network_id    = module.network.vnet_id
  tags                  = local.common_tags
}

resource "azurerm_private_endpoint" "redis" {
  count = local.redis_enabled ? 1 : 0

  name                = "${var.resource_name_prefix}-redis-pe"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.redis[0].id
  tags                = local.common_tags

  private_service_connection {
    name                           = "${var.resource_name_prefix}-redis-connection"
    private_connection_resource_id = azurerm_managed_redis.cache[0].id
    subresource_names              = ["redisEnterprise"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "redis"
    private_dns_zone_ids = [azurerm_private_dns_zone.redis[0].id]
  }

  depends_on = [azurerm_subnet_network_security_group_association.redis]
}
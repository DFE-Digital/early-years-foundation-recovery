locals {
  redis_enabled = contains(["staging", "production"], var.environment)
}

resource "azurerm_redis_cache" "redis" {
  count = local.redis_enabled ? 1 : 0

  name                          = "${var.resource_name_prefix}-redis"
  location                      = var.azure_region
  resource_group_name           = azurerm_resource_group.rg.name
  capacity                      = 0
  family                        = "C"
  sku_name                      = "Standard"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  tags                          = local.common_tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_endpoint" "redis" {
  count = local.redis_enabled ? 1 : 0

  name                = "${var.resource_name_prefix}-redis-pe"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.azure_region
  subnet_id           = module.network.redis_private_endpoint_subnet_id
  tags                = local.common_tags

  private_service_connection {
    name                           = "${var.resource_name_prefix}-redis-psc"
    private_connection_resource_id = azurerm_redis_cache.redis[0].id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [module.network.redis_private_dns_zone_id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

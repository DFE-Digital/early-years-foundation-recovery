output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "db_subnet_id" {
  description = "ID of the delegated Subnet for the Database"
  value       = azurerm_subnet.db_snet.id
}

output "db_dns_zone_id" {
  description = "ID of the Private DNS Zone for the Database"
  value       = azurerm_private_dns_zone.db_dnsz.id
}
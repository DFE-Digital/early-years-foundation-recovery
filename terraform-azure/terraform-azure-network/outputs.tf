output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "psqlfs_subnet_id" {
  description = "ID of the delegated Subnet for the Database Server"
  value       = azurerm_subnet.psqlfs_snet.id
}

output "psqlfs_dns_zone_id" {
  description = "ID of the Private DNS Zone for the Database Server"
  value       = azurerm_private_dns_zone.psqlfs_dnsz.id
}
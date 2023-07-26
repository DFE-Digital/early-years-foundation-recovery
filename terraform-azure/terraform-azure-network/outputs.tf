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

output "webapp_subnet_id" {
  description = "ID of the delegated Subnet for the Web Application"
  value       = azurerm_subnet.webapp_snet.id
}

output "app_worker_subnet_id" {
  description = "ID of the delegated Subnet for the Background Worker"
  value       = azurerm_subnet.app_worker_snet.id
}

output "reviewapp_subnet_id" {
  description = "ID of the delegated Subnet for the Review Application"
  value       = azurerm_subnet.reviewapp_snet == [] ? null : azurerm_subnet.reviewapp_snet[0].id
}
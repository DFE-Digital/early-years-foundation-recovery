resource "random_pet" "name" {
  length = 1
}

# Create Database Server
resource "azurerm_postgresql_flexible_server" "psqlfs" {
  name                   = "${var.resource_name_prefix}-psqlfs"
  resource_group_name    = var.resource_group
  location               = var.location
  version                = "13"
  delegated_subnet_id    = var.psqlfs_subnet_id
  private_dns_zone_id    = var.psqlfs_dns_zone_id
  administrator_login    = var.psqlfs_username
  administrator_password = var.psqlfs_password
  zone                   = "1"
  storage_mb             = var.psqlfs_storage
  sku_name               = var.psqlfs_sku
  backup_retention_days  = 7
}

# Create Database
resource "azurerm_postgresql_flexible_server_database" "psqldb" {
  name      = "${var.resource_name_prefix}-${random_pet.name.id}-psqldb"
  server_id = azurerm_postgresql_flexible_server.psqlfs.id
  collation = "en_US.UTF8"
  charset   = "UTF8"
}
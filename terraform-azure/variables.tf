variable "azure_region" {
  default     = "westeurope"
  description = "Name of the Azure region to deploy resources"
  type        = string
}

variable "environment" {
  default     = "development"
  description = "Environment to deploy resources"
  type        = string
}

variable "resource_name_prefix" {
  default     = "s187d01-eyrecovery"
  description = "Prefix for resource names"
  type        = string
}

variable "psqlfs_sku" {
  default     = "B_Standard_B1ms"
  description = "SKU name for the Database Server"
  type        = string
}

variable "psqlfs_storage" {
  default     = 32768
  description = "Max storage allowed for the Database Server"
  type        = number
}

variable "psqlfs_username" {
  default     = "psqladmin"
  description = "Username of the Database Server"
  type        = string
}

variable "psqlfs_password" {
  default     = "psqlp@55w0rd"
  description = "Password of the Database Server"
  type        = string
}

variable "psqlfs_geo_redundant_backup" {
  default     = false
  description = "Geo-redundant backup storage enabled"
  type        = bool
}
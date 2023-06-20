variable "default_azure_region" {
  default     = "westeurope"
  description = "Name of the Azure region to deploy resources"
  type        = string
}

variable "default_environment" {
  default     = "dev"
  description = "Environment to deploy resourcces"
  type        = string
}

variable "resource_name_prefix" {
  default     = "s187d01-eyrecovery"
  description = "Prefix for resource names"
  type        = string
}
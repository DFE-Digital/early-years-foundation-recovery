variable "location" {
  description = "Name of the Azure region to deploy resources"
  type        = string
}

variable "resource_group" {
  description = "Name of the Azure Resource Group to deploy resources"
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "asp_sku" {
  description = "SKU name for the App Service Plan"
  type        = string
}

variable "webapp_name" {
  description = "Name for the Web Application"
  type        = string
}

variable "webapp_subnet_id" {
  description = "ID of the delegated Subnet for the Web Application"
  type        = string
}

variable "webapp_database_url" {
  description = "URL to the database"
  type        = string
  sensitive   = true
}

variable "webapp_docker_registry_url" {
  description = "URL to the Docker Registry"
  type        = string
}

variable "webapp_docker_registry_username" {
  description = "Username for the Docker Registry"
  type        = string
}

variable "webapp_docker_registry_password" {
  description = "Password the Docker Registry"
  type        = string
  sensitive   = true
}

variable "webapp_docker_image_url" {
  description = "URL to the Docker Image"
  type        = string
}

variable "webapp_docker_image_tag" {
  description = "Tag for the Docker Image"
  type        = string
}

variable "webapp_startup_command" {
  description = "Startup command to pass into the Web Application"
  type        = string
}
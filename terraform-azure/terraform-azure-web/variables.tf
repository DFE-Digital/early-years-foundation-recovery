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

variable "webapp_app_settings" {
  description = "App Settings are exposed as environment variables"
  type        = map(string)
}

variable "webapp_docker_image_url" {
  description = "URL to the Docker Image"
  type        = string
}

variable "webapp_docker_image_tag" {
  description = "Tag for the Docker Image"
  type        = string
}

variable "webapp_health_check_path" {
  description = "Path to health check endpoint"
  type        = string
}

variable "health_check_eviction_time_in_min" {
  default     = 10
  description = "Minutes before considering an instance unhealthy"
  type        = number
}
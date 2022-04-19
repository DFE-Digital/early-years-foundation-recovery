# Terraform
# ------------------------------------------------------------------------------
variable "app_environment" {
  type        = string
  description = "Terraform workspace: content/staging/production"
  default     = "staging"
}

variable "service_name" {
  type        = string
  description = "Your project"
  default     = "dfe-project"
}


# Cloud Foundry
# ------------------------------------------------------------------------------
variable "cf_api_url" {}
variable "cf_space_name" {}
variable "cf_user" {}
variable "cf_password" {}
variable "cf_sso_passcode" {}


# Docker
# ------------------------------------------------------------------------------
variable "app_docker_image" {}


# APP
# ------------------------------------------------------------------------------
variable "web_app_env" {
  type = object
  description = "Application Environment Variables"
  default = {}
}

variable "web_app_name" {
  type        = string
  description = "Domain Hostname"
}

variable "web_app_instances" {
  type    = number
  default = 1
}

variable "web_app_memory" {
  type    = number
  default = 512
}

variable "web_app_start_command" {
  type        = string
  description = "Application Server"
  default     = "bundle exec rails server -b 0.0.0.0"
}

variable "web_app_start_timeout" {
  type    = number
  default = 300
}

variable "web_app_stopped" {
  type    = bool
  default = false
}

variable "web_app_deployment_strategy" {
  type    = string
  default = "blue-green-v2"
}


# DB (deployment time 5m9s)
# ------------------------------------------------------------------------------

variable "postgres_create_timeout" {
  type    = string
  default = "15m"
}

variable "postgres_service_plan" {
  type        = string
  description = "$ cf marketplace -e postgres"
  default     = "tiny-unencrypted-11"
}

variable "app_environment" {
  type        = string
  description = "Deployment type: review/staging/production"
  default     = "demo"
}

variable "service_name" {
  type        = string
  description = "Your project"
  default     = "dfe-project"
}


# Cloud Foundry
variable "cf_api_url" {}
variable "cf_user" {}
variable "cf_password" {}
variable "cf_sso_passcode" {}
variable "cf_space_name" {}


# Docker
variable "app_docker_image" {}

variable "app_env_values" {}


# APP
# ------------------------------------------------------------------------------

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


# DB
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

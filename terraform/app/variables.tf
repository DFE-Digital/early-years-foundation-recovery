# ------------------------------------------------------------------------------
# Config

variable "paas_app_config_file" {
  type        = string
  description = "Path to YAML config"
  default     = "app_config.yml"
}


# ------------------------------------------------------------------------------
# Environments

variable "paas_app_environment" {
  type        = string
  description = "Deployment type: review/staging/production"
  default     = "development"
}

#
variable "paas_app_env_secrets" {
  description = "GH environment secrets as JSON"
  default     = {}
}

variable "paas_app_docker_image" {
  default = ""
}


# ------------------------------------------------------------------------------
# Cloud Foundry

variable "paas_cf_user" {}
variable "paas_cf_password" {}
variable "paas_cf_sso_passcode" {}
variable "paas_cf_space_name" {}


# ------------------------------------------------------------------------------
# Application

variable "paas_web_app_start_command" {
  default = "bundle exec rake db:prepare && bundle exec rails s -b 0.0.0.0"
}

variable "paas_web_app_instances" {
  default = 1
  type    = number
}

variable "paas_web_app_memory" {
  default = 512
  type    = number
}

# set on review.tfvars, workflow action timedout before paas was ready
variable "paas_web_app_start_timeout" {
  default = 360
  type    = number
}

# ------------------------------------------------------------------------------
# Database

variable "paas_postgres_service_plan" {
  default = "tiny-unencrypted-11"
  type    = string
}

variable "paas_postgres_create_timeout" {
  default = "15m"
  type    = string
}

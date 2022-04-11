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

variable "paas_app_hostname" {
  type        = string
  description = "appended to service name unless blank"
  default     = ""
}

#
variable "paas_app_env_secrets" {
  type        = map(string)
  description = "GH environment secrets as JSON mapped to object"
  default     = {}
}

variable "paas_app_docker_image" {
  default = ""
}


# ------------------------------------------------------------------------------
# Cloud Foundry

variable "paas_cf_space_name" {}
variable "paas_cf_user" {
  default = ""
}
variable "paas_cf_password" {
  default = ""
}
variable "paas_cf_sso_passcode" {
  default = ""
}

# ------------------------------------------------------------------------------
# Application

variable "paas_web_app_start_command" {
  default = "bundle exec rails server -b 0.0.0.0"
}

variable "paas_web_app_instances" {
  default = 1
}

variable "paas_web_app_memory" {
  default = 512
}

# set on review.tfvars, workflow action timed out before paas was ready
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

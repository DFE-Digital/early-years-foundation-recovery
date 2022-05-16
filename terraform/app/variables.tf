# ------------------------------------------------------------------------------
# Environment

variable "paas_app_environment" {
  type        = string
  description = "Terraform workspace name"
  default     = "production"
}

# merged into paas_app_env_values

# 1.
variable "paas_app_config_file" {
  type        = string
  description = "Terraform workspace application variables"
  default     = "app_config.yml"
}

# 2.
variable "paas_app_env_secrets" {
  type        = map(string)
  description = "GH environment secrets as JSON mapped to object"
  default     = {}
}

# 3.
variable "paas_app_envs" {
  type        = map(string)
  description = "GH workflow envs as JSON mapped to object"
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

variable "paas_app_hostname" {
  type        = string
  description = "appended to service name unless blank"
  default     = ""
}

variable "paas_web_app_start_command" {
  # default = "bundle exec rails server -b 0.0.0.0"
  default = "bundle exec rails db:prepare && bundle exec rails server -b 0.0.0.0"
}

variable "paas_web_app_instances" {}

variable "paas_web_app_memory" {}

variable "paas_web_app_start_timeout" {}

# ------------------------------------------------------------------------------
# Database

variable "paas_postgres_service_plan" {}

variable "paas_postgres_create_timeout" {}

variable "paas_postgres_json_params" {}

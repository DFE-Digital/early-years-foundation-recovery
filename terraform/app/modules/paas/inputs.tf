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
  description = "Application environment variables"
  default     = {}
}

variable "web_app_name" {
  type        = string
  description = "Application domain hostname"
}

variable "web_app_instances" {
  type        = number
  description = "Application instances"
  default     = 1
}

variable "web_app_memory" {
  type        = number
  description = "Application memory"
  default     = 512
}

variable "web_app_disk_quota" {
  type        = number
  description = "Application disk quota"
  default     = 2048
  # default     = 3072
}

variable "web_app_start_command" {
  type        = string
  description = "Application start command"
  default     = "bundle exec rails server -b 0.0.0.0"
}

# set on review.tfvars
# NB: Reform experienced workflow action timed out before paas was ready
variable "web_app_start_timeout" {
  type    = number
  default = 360
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
  default     = "tiny-unencrypted-13"
}

# "{\"enable_extensions\": [\"pgcrypto\", \"fuzzystrmatch\", \"plpgsql\"]}"
variable "postgres_json_params" {
  description = "Postgres JSON params"
  default = {
    enable_extensions = [
      "pgcrypto",
      "fuzzystrmatch",
      "plpgsql",
    ]
  }
  type = map(any)
}

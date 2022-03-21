variable "environment" {
  description = "Environment"
  type        = string
}

# ------------------------------------------------------------------------------
# Application

variable paas_web_app_instances {
  default = 1
}

variable paas_web_app_memory {
  default = 512
}

variable paas_web_app_deployment_strategy {
  default = "blue-green-v2"
}


# ------------------------------------------------------------------------------
# Database

variable paas_postgres_service_plan {
  default = "tiny-unencrypted-11"
}

variable paas_postgres_create_timeout {
  default = "15m"
}

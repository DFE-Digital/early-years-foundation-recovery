variable environment {
  description = "Environment"
  type        = string
}


# ------------------------------------------------------------------------------
# Cloud Foundry

variable paas_cf_user {}
variable paas_cf_password {}
variable paas_cf_sso_passcode {}

# ------------------------------------------------------------------------------
# Gov PaaS


variable paas_app_environment {
  default = "development"
}

variable paas_space_name {
  default = "eyfs-recovery"
}

variable paas_app_stopped {
  default = false
}

variable paas_app_start_timeout {
  default = 300
}


# ------------------------------------------------------------------------------
# Application

variable paas_web_app_start_command {
  default = "bundle exec rake db:prepare && bundle exec rails s -b 0.0.0.0"
}

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

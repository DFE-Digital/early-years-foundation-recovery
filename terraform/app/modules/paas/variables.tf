# Cloud Foundry
variable cf_api_url {}
variable cf_user {}
variable cf_password {}
variable cf_sso_passcode {}



variable app_docker_image {}

variable app_env_values {}

variable app_start_timeout {
  default = 300
}

variable app_stopped {
  default = false
}

variable postgres_create_timeout {
  default = "15m"
}

variable postgres_service_plan {}

variable service_name {}

variable space_name {}

variable web_app_deployment_strategy {}

variable web_app_instances {
  default = 1
}

variable web_app_memory {
  default = 512
}

variable web_app_start_command {}

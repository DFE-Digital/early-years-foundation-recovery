provider cloudfoundry {
  api_url           = var.paas_api_url
  user              = var.paas_user != "" ? var.paas_user : null
  password          = var.paas_password != "" ? var.paas_password : null
  sso_passcode      = var.paas_sso_passcode != "" ? var.paas_sso_passcode : null
  store_tokens_path = "./tokens"
}


resource cloudfoundry_app web_app {
  name                        = local.web_app_name
  environment                 = local.paas_app_environment

  health_check_type           = "http"
  health_check_http_endpoint  = "/check"
  # health_check_http_endpoint  = "/ping"

  command                     = var.web_app_start_command
  instances                   = var.web_app_instances
  memory                      = var.web_app_memory
  docker_image                = var.app_docker_image

  space                       = data.cloudfoundry_space.space.id
  stopped                     = var.app_stopped
  strategy                    = var.web_app_deployment_strategy
  timeout                     = var.app_start_timeout


  dynamic "service_binding" {
    for_each = local.app_service_bindings
    content {
      service_instance = service_binding.value
      params_json = <<JSON
        { "read_only": true }
      JSON
    }
  }

  routes {
    route = cloudfoundry_route.web_app_route.id
  }
}

resource cloudfoundry_route web_app_route {
  domain    = data.cloudfoundry_domain.cloudapps_digital.id
  space     = data.cloudfoundry_space.space.id
  hostname  = local.web_app_name
}


resource cloudfoundry_service_instance postgres_instance {
  name          = local.postgres_service_name
  space         = data.cloudfoundry_space.space.id
  service_plan  = data.cloudfoundry_service.postgres.service_plans[var.postgres_service_plan]
  json_params   = "{\"enable_extensions\": [\"pgcrypto\", \"fuzzystrmatch\", \"plpgsql\"]}"

  timeouts {
    create = var.postgres_create_timeout
  }
}

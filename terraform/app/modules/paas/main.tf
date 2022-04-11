terraform {
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = ">= 0.14.5"
    }
  }
}

# For username / password authentication:
#   - user
#   - password
#
# For SSO authentication
#   - sso_passcode
#   - store_tokens_path = /path/to/local/file
#
provider "cloudfoundry" {
  api_url           = var.cf_api_url
  user              = var.cf_user != "" ? var.cf_user : null
  password          = var.cf_password != "" ? var.cf_password : null
  sso_passcode      = var.cf_sso_passcode != "" ? var.cf_sso_passcode : null
  store_tokens_path = "./tokens"
}


resource "cloudfoundry_app" "web_app" {
  name                       = local.web_app_name        # <project>-<env>
  environment                = local.app_environment     # {}
  command                    = var.web_app_start_command # rails s -b 0.0.0.0
  instances                  = var.web_app_instances     # default: 1
  memory                     = var.web_app_memory        # default: 512
  health_check_type          = "http"
  health_check_http_endpoint = "/health"
  stopped                    = false
  strategy                   = "blue-green-v2"
  timeout                    = 300
  docker_image               = var.app_docker_image
  space                      = data.cloudfoundry_space.space.id


  dynamic "service_binding" {
    for_each = local.app_service_bindings
    content {
      service_instance = service_binding.value
      params_json      = <<JSON
        { "read_only": true }
      JSON
    }
  }

  routes {
    route = cloudfoundry_route.web_app_route.id
  }
}

resource "cloudfoundry_route" "web_app_route" {
  domain   = data.cloudfoundry_domain.cloudapps_digital.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.web_app_name
}


resource "cloudfoundry_service_instance" "postgres_instance" {
  name         = local.postgres_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.postgres_service_plan]
  json_params  = "{\"enable_extensions\": [\"pgcrypto\", \"fuzzystrmatch\", \"plpgsql\"]}"

  timeouts {
    create = var.postgres_create_timeout
  }
}

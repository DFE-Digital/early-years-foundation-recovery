# Create App Service Plan
resource "azurerm_service_plan" "asp" {
  name                = "${var.resource_name_prefix}-asp"
  location            = var.location
  resource_group_name = var.resource_group
  os_type             = "Linux"
  sku_name            = var.asp_sku

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create Web Application
# TODO: app_settings should be passed in as a dictionary/map
resource "azurerm_linux_web_app" "webapp" {
  name                = var.webapp_name
  location            = var.location
  resource_group_name = var.resource_group
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true
  app_settings = {
    DATABASE_URL                        = var.webapp_database_url
    DOCKER_REGISTRY_SERVER_URL          = var.webapp_docker_registry_url
    DOCKER_REGISTRY_SERVER_USERNAME     = var.webapp_docker_registry_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = var.webapp_docker_registry_password
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }

  site_config {
    app_command_line       = var.webapp_startup_command
    vnet_route_all_enabled = true

    application_stack {
      docker_image     = var.webapp_docker_image_url
      docker_image_tag = var.webapp_docker_image_tag
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Integrate Web Application into Virtual Network
resource "azurerm_app_service_virtual_network_swift_connection" "webapp_vnet" {
  app_service_id = azurerm_linux_web_app.webapp.id
  subnet_id      = var.webapp_subnet_id
}
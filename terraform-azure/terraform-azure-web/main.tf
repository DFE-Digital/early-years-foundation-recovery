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

  #checkov:skip=CKV_AZURE_212:Argument not available
}

# Create Web Application
resource "azurerm_linux_web_app" "webapp" {
  name                = var.webapp_name
  location            = var.location
  resource_group_name = var.resource_group
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true
  app_settings        = var.webapp_app_settings

  site_config {
    health_check_path                 = var.webapp_health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min
    http2_enabled                     = true
    vnet_route_all_enabled            = true

    application_stack {
      docker_image     = var.webapp_docker_image_url
      docker_image_tag = var.webapp_docker_image_tag
    }
  }

  sticky_settings {
    app_setting_names = keys(var.webapp_app_settings)
  }

  logs {
    detailed_error_messages = true

    application_logs {
      file_system_level = "Verbose"
    }

    #TODO: Configure Blob Storage
  }

  lifecycle {
    ignore_changes = [tags]
  }

  #checkov:skip=CKV_AZURE_13:App uses built-in authentication
  #checkov:skip=CKV_AZURE_88:Using Docker
  #checkov:skip=CKV_AZURE_17:Argument not available
  #checkov:skip=CKV_AZURE_78:Disabled by default in Terraform version used
  #checkov:skip=CKV_AZURE_16:Using VNET Integration
  #checkov:skip=CKV_AZURE_71:Using VNET Integration
}

# Create Web Application Deployment Slot
resource "azurerm_linux_web_app_slot" "webapp_slot" {
  name           = "green"
  app_service_id = azurerm_linux_web_app.webapp.id
  https_only     = true
  app_settings   = var.webapp_app_settings

  site_config {
    health_check_path                 = var.webapp_health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min
    http2_enabled                     = true
    vnet_route_all_enabled            = true

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

# Integrate Web Application Deployment Slot into Virtual Network
resource "azurerm_app_service_slot_virtual_network_swift_connection" "webapp_slot_vnet" {
  slot_name      = azurerm_linux_web_app_slot.webapp_slot.name
  app_service_id = azurerm_linux_web_app.webapp.id
  subnet_id      = var.webapp_subnet_id
}
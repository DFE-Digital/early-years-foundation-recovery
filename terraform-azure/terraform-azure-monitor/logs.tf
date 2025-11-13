# Create Log Analytics
resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "${var.resource_name_prefix}-log"
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = 1

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                       = "${var.resource_name_prefix}-appinsights"
  resource_group_name        = var.resource_group
  location                   = var.location
  application_type           = "web"
  workspace_id               = azurerm_log_analytics_workspace.log_analytics.id
  internet_ingestion_enabled = true
  internet_query_enabled     = true
}
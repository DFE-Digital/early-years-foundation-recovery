# Diagnostic settings to forward Key Vault audit logs and metrics to Log Analytics,
# enabling monitoring of access attempts and configuration changes
resource "azurerm_monitor_diagnostic_setting" "kv_diagnostics" {
  # Key Vault only deployed to the Test and Production subscription
  count = var.environment != "development" ? 1 : 0

  name                       = "${var.resource_name_prefix}-kv-mon"
  target_resource_id         = azurerm_key_vault.kv[0].id
  log_analytics_workspace_id = var.logs_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  metric {
    category = "AllMetrics"
  }

  timeouts {
    read = "30m"
  }

  lifecycle {
    ignore_changes = [metric]
  }
}

# Action group used to notify administrators of Key Vault security events
resource "azurerm_monitor_action_group" "kv_alerts_ag" {
  # Key Vault only deployed to the Test and Production subscription
  count = var.environment != "development" ? 1 : 0

  name                = "${var.resource_name_prefix}-kv-ag"
  resource_group_name = var.resource_group
  short_name          = "kvalerts"

  email_receiver {
    name          = "security-admin"
    email_address = var.admin_email_address
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Alert on administrative/control-plane changes to the Key Vault, e.g. updates to
# access control, networking or vault configuration
resource "azurerm_monitor_activity_log_alert" "kv_admin_changes_alert" {
  # Key Vault only deployed to the Test and Production subscription
  count = var.environment != "development" ? 1 : 0

  name                = "${var.resource_name_prefix}-kv-admin-alert"
  resource_group_name = var.resource_group
  scopes              = [azurerm_key_vault.kv[0].id]
  description         = "Alerts when the Key Vault's configuration, network rules or access control are changed"

  criteria {
    resource_id    = azurerm_key_vault.kv[0].id
    category       = "Administrative"
    operation_name = "Microsoft.KeyVault/vaults/write"
  }

  action {
    action_group_id = azurerm_monitor_action_group.kv_alerts_ag[0].id
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Alert on failed/unauthorised access attempts against keys, secrets and
# certificates stored in the Key Vault (data-plane operations)
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "kv_access_failure_alert" {
  # Key Vault only deployed to the Test and Production subscription
  count = var.environment != "development" ? 1 : 0

  name                 = "${var.resource_name_prefix}-kv-access-alert"
  resource_group_name  = var.resource_group
  location             = var.location
  evaluation_frequency = "PT15M"
  window_duration      = "PT15M"
  scopes               = [var.logs_id]
  severity             = 2
  description          = "Alerts when unauthorised or failed access attempts are made against the Key Vault"

  criteria {
    query = <<-QUERY
      AzureDiagnostics
      | where ResourceProvider == "MICROSOFT.KEYVAULT"
      | where Resource =~ "${azurerm_key_vault.kv[0].name}"
      | where ResultType != "Success"
    QUERY

    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.kv_alerts_ag[0].id]
  }

  depends_on = [azurerm_monitor_diagnostic_setting.kv_diagnostics]

  lifecycle {
    ignore_changes = [tags]
  }
}

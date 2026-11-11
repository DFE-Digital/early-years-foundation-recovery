locals {
  key_vault_monitoring_targets = merge(
    { rbac = azurerm_key_vault.rbackv.id },
    var.environment != "development" ? { legacy = azurerm_key_vault.kv[0].id } : {}
  )
}

resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  for_each = local.key_vault_monitoring_targets

  name                           = "${var.resource_name_prefix}-${each.key}-kv-diag"
  target_resource_id             = each.value
  log_analytics_workspace_id     = var.logs_id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_action_group" "key_vault" {
  name                = "${var.resource_name_prefix}-kv-alerts"
  resource_group_name = var.resource_group
  short_name          = "kv-security"

  email_receiver {
    name                    = "key-vault-security"
    email_address           = var.key_vault_alert_email
    use_common_alert_schema = true
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_monitor_activity_log_alert" "key_vault_changes" {
  for_each = local.key_vault_monitoring_targets

  name                = "${var.resource_name_prefix}-${each.key}-kv-changes"
  resource_group_name = var.resource_group
  scopes              = ["/subscriptions/${data.azurerm_client_config.az_config.subscription_id}"]
  description         = "Alert on Azure control-plane changes to Key Vault."

  criteria {
    category          = "Administrative"
    resource_id       = each.value
    resource_type     = "Microsoft.KeyVault/vaults"
    resource_provider = "Microsoft.KeyVault"
  }

  action {
    action_group_id = azurerm_monitor_action_group.key_vault.id
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "key_vault_failed_access" {
  for_each = local.key_vault_monitoring_targets

  name                  = "${var.resource_name_prefix}-${each.key}-kv-failed-access"
  resource_group_name   = var.resource_group
  location              = var.location
  scopes                = [var.logs_id]
  description           = "Alert on failed Key Vault data-plane operations."
  severity              = 2
  enabled               = true
  evaluation_frequency  = "PT5M"
  window_duration       = "PT5M"
  skip_query_validation = true

  criteria {
    query = <<-QUERY
      AZKVAuditLogs
      | where _ResourceId =~ "${each.value}"
      | where ResultType !in~ ("Success", "OK")
      | summarize EventCount = count()
    QUERY

    time_aggregation_method = "Total"
    metric_measure_column   = "EventCount"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.key_vault.id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "key_vault_sensitive_changes" {
  for_each = local.key_vault_monitoring_targets

  name                  = "${var.resource_name_prefix}-${each.key}-kv-data-changes"
  resource_group_name   = var.resource_group
  location              = var.location
  scopes                = [var.logs_id]
  description           = "Alert on Key Vault secret, key, or certificate changes."
  severity              = 2
  enabled               = true
  evaluation_frequency  = "PT5M"
  window_duration       = "PT5M"
  skip_query_validation = true

  criteria {
    query = <<-QUERY
      AZKVAuditLogs
      | where _ResourceId =~ "${each.value}"
      | where OperationName has_any (
          "SecretSet", "SecretUpdate", "SecretDelete", "SecretPurge",
          "SecretBackup", "SecretRestore", "SecretRecover",
          "KeyCreate", "KeyImport", "KeyDelete", "KeyUpdate", "KeyPurge",
          "KeyBackup", "KeyRestore", "KeyRecover", "KeyRotate", "KeyRotateIfDue",
          "KeyRotationPolicySet",
          "CertificateCreate", "CertificateImport", "CertificateUpdate", "CertificateDelete",
          "CertificatePurge", "CertificateBackup", "CertificateRestore", "CertificateRecover",
          "CertificatePolicyUpdate", "CertificatePolicySet",
          "CertificateIssuerSet", "CertificateIssuerUpdate", "CertificateIssuerDelete",
          "CertificateEnroll", "CertificateRenew", "CertificatePendingMerge",
          "CertificatePendingUpdate", "CertificatePendingDelete"
        )
      | summarize EventCount = count()
    QUERY

    time_aggregation_method = "Total"
    metric_measure_column   = "EventCount"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.key_vault.id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_monitor_activity_log_alert" "key_vault_role_changes" {
  name                = "${var.resource_name_prefix}-kv-role-changes"
  resource_group_name = var.resource_group
  scopes              = ["/subscriptions/${data.azurerm_client_config.az_config.subscription_id}"]
  description         = "Alert on role assignment changes in the application resource group, including Key Vault access."

  criteria {
    category          = "Administrative"
    resource_group    = var.resource_group
    resource_provider = "Microsoft.Authorization"
    resource_type     = "Microsoft.Authorization/roleAssignments"
  }

  action {
    action_group_id = azurerm_monitor_action_group.key_vault.id
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
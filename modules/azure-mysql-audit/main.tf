#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

locals {
  udc_name        = format("%s-%s", var.mysql_server_name, local.subscription_id)
  subscription_id = data.azurerm_client_config.current.subscription_id
  azure_region    = var.azure_region
}

data "azurerm_client_config" "current" {}

# Get MySQL Server details
data "azurerm_mysql_flexible_server" "mysql" {
  name                = var.mysql_server_name
  resource_group_name = var.resource_group_name
}

# Get Event Hub namespace details
data "azurerm_eventhub_namespace" "eventhub" {
  name                = var.eventhub_namespace_name
  resource_group_name = var.resource_group_name
}

# Get Event Hub details
data "azurerm_eventhub" "eventhub" {
  name                = var.eventhub_name
  namespace_name      = var.eventhub_namespace_name
  resource_group_name = var.resource_group_name
}

# Get Storage Account details (for Event Hub checkpointing)
data "azurerm_storage_account" "checkpoint" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Get Event Hub namespace authorization rule for diagnostic settings
data "azurerm_eventhub_namespace_authorization_rule" "eventhub_auth" {
  name                = var.eventhub_authorization_rule_name
  namespace_name      = var.eventhub_namespace_name
  resource_group_name = var.resource_group_name
}

# Get Event Hub authorization rule for UC connection string
data "azurerm_eventhub_authorization_rule" "eventhub_sas_policy" {
  name                = var.eventhub_sas_policy_name
  namespace_name      = var.eventhub_namespace_name
  eventhub_name       = var.eventhub_name
  resource_group_name = var.resource_group_name
}

# Optional MySQL firewall rules for client access
resource "azurerm_mysql_flexible_server_firewall_rule" "custom_rules" {
  for_each            = var.firewall_rules
  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = var.mysql_server_name
  start_ip_address    = each.value.start_ip
  end_ip_address      = each.value.end_ip
}

######
## MySQL Audit Configuration
######

# Enable MySQL audit logging on the server
resource "azurerm_mysql_flexible_server_configuration" "audit_log_enabled" {
  name                = "audit_log_enabled"
  resource_group_name = var.resource_group_name
  server_name         = var.mysql_server_name
  value               = var.enable_mysql_audit_logs ? "ON" : "OFF"
}

# Configure audit log events
resource "azurerm_mysql_flexible_server_configuration" "audit_log_events" {
  count               = var.enable_mysql_audit_logs ? 1 : 0
  name                = "audit_log_events"
  resource_group_name = var.resource_group_name
  server_name         = var.mysql_server_name
  value               = var.audit_log_events
}

# Configure diagnostic settings to stream MySQL audit logs to Event Hub
resource "azurerm_monitor_diagnostic_setting" "mysql_audit" {
  name                           = var.diagnostic_setting_name
  target_resource_id             = data.azurerm_mysql_flexible_server.mysql.id
  eventhub_name                  = data.azurerm_eventhub.eventhub.name
  eventhub_authorization_rule_id = data.azurerm_eventhub_namespace_authorization_rule.eventhub_auth.id
  storage_account_id             = data.azurerm_storage_account.checkpoint.id

  # Enable MySQL Audit logs
  dynamic "enabled_log" {
    for_each = var.enable_mysql_audit_logs ? [1] : []
    content {
      category = "MySqlAuditLogs"
    }
  }

  depends_on = [
    data.azurerm_mysql_flexible_server.mysql,
    data.azurerm_eventhub.eventhub,
    data.azurerm_eventhub_namespace_authorization_rule.eventhub_auth,
    data.azurerm_storage_account.checkpoint,
    azurerm_mysql_flexible_server_configuration.audit_log_enabled,
    azurerm_mysql_flexible_server_configuration.audit_log_events
  ]
}

//////
// Universal Connector Module - Can be disabled with enable_universal_connector = false
//////

locals {
  # Build Event Hub connection string
  event_hub_connection = format("Endpoint=sb://%s.servicebus.windows.net/;SharedAccessKeyName=%s;SharedAccessKey=%s;EntityPath=%s",
    var.eventhub_namespace_name,
    var.eventhub_sas_policy_name,
    data.azurerm_eventhub_authorization_rule.eventhub_sas_policy.primary_key,
    var.eventhub_name
  )

  # Build Storage connection string
  storage_connection = format("DefaultEndpointsProtocol=https;AccountName=%s;AccountKey=%s;EndpointSuffix=core.windows.net",
    var.storage_account_name,
    data.azurerm_storage_account.checkpoint.primary_access_key
  )
}

module "common_azure-eventhub-registration" {
  source = "IBM/common/guardium//modules/azure-eventhub-registration"

  # Profile Configuration
  profile_definition_name = "Azure MySQL over Event Hub"
  udc_name                = var.mysql_server_name
  description             = "GDP Azure MySQL connector for ${var.mysql_server_name}"

  # Azure Configuration
  azure_region          = var.azure_region
  azure_subscription_id = local.subscription_id
  azure_enrollment_id   = var.azure_enrollment_id

  # Event Hub Configuration
  event_hub_connections = local.event_hub_connection
  storage_connection    = local.storage_connection
  consumer_group        = var.consumer_group
  config_mode           = var.config_mode
  threads               = var.threads
  decorate_events       = var.decorate_events

  # Guardium Configuration
  gdp_client_id              = var.gdp_client_id
  gdp_client_secret          = var.gdp_client_secret
  gdp_server                 = var.gdp_server
  gdp_port                   = var.gdp_port
  gdp_username               = var.gdp_username
  gdp_password               = var.gdp_password
  gdp_mu_host                = var.gdp_mu_host
  enable_universal_connector = var.enable_universal_connector
  csv_start_position         = var.initial_position
}

#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

locals {
  udc_name        = format("%s-%s", var.postgres_server_name, local.subscription_id)
  subscription_id = data.azurerm_client_config.current.subscription_id
  azure_region    = data.azurerm_resource_group.rg.location
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Get PostgreSQL Flexible Server
data "azurerm_postgresql_flexible_server" "postgres" {
  name                = var.postgres_server_name
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

# Get Storage Account details for connection string
data "azurerm_storage_account" "checkpoint" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Optional PostgreSQL firewall rules for client access
resource "azurerm_postgresql_flexible_server_firewall_rule" "custom_rules" {
  for_each         = var.firewall_rules
  name             = each.key
  server_id        = data.azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}

######
# PostgreSQL pgAudit Configuration
######

# Enable pgaudit extension in shared_preload_libraries
resource "azurerm_postgresql_flexible_server_configuration" "shared_preload_libraries" {
  name      = "shared_preload_libraries"
  server_id = data.azurerm_postgresql_flexible_server.postgres.id
  value     = "PGAUDIT"
}

# Configure pgaudit.log parameter
resource "azurerm_postgresql_flexible_server_configuration" "pgaudit_log" {
  name      = "pgaudit.log"
  server_id = data.azurerm_postgresql_flexible_server.postgres.id
  value     = lower(var.pgaudit_log)

  depends_on = [azurerm_postgresql_flexible_server_configuration.shared_preload_libraries]
}

# Configure pgaudit.log_catalog
resource "azurerm_postgresql_flexible_server_configuration" "pgaudit_log_catalog" {
  name      = "pgaudit.log_catalog"
  server_id = data.azurerm_postgresql_flexible_server.postgres.id
  value     = var.pgaudit_log_catalog ? "on" : "off"

  depends_on = [azurerm_postgresql_flexible_server_configuration.shared_preload_libraries]
}

# Configure pgaudit.log_client
resource "azurerm_postgresql_flexible_server_configuration" "pgaudit_log_client" {
  name      = "pgaudit.log_client"
  server_id = data.azurerm_postgresql_flexible_server.postgres.id
  value     = var.pgaudit_log_client ? "on" : "off"

  depends_on = [azurerm_postgresql_flexible_server_configuration.shared_preload_libraries]
}

# Configure pgaudit.log_parameter
resource "azurerm_postgresql_flexible_server_configuration" "pgaudit_log_parameter" {
  name      = "pgaudit.log_parameter"
  server_id = data.azurerm_postgresql_flexible_server.postgres.id
  value     = var.pgaudit_log_parameter ? "on" : "off"

  depends_on = [azurerm_postgresql_flexible_server_configuration.shared_preload_libraries]
}

# Configure log_checkpoints
resource "azurerm_postgresql_flexible_server_configuration" "log_checkpoints" {
  name      = "log_checkpoints"
  server_id = data.azurerm_postgresql_flexible_server.postgres.id
  value     = var.log_checkpoints ? "on" : "off"
}

# Configure log_error_verbosity
resource "azurerm_postgresql_flexible_server_configuration" "log_error_verbosity" {
  name      = "log_error_verbosity"
  server_id = data.azurerm_postgresql_flexible_server.postgres.id
  value     = var.log_error_verbosity
}

# Configure log_line_prefix
resource "azurerm_postgresql_flexible_server_configuration" "log_line_prefix" {
  name      = "log_line_prefix"
  server_id = data.azurerm_postgresql_flexible_server.postgres.id
  value     = var.log_line_prefix
}

######
# Diagnostic Settings for PostgreSQL
######

# Create diagnostic setting to stream logs to Event Hub
resource "azurerm_monitor_diagnostic_setting" "postgres_audit" {
  name                           = var.diagnostic_setting_name
  target_resource_id             = data.azurerm_postgresql_flexible_server.postgres.id
  eventhub_authorization_rule_id = data.azurerm_eventhub_namespace_authorization_rule.eventhub_auth.id
  eventhub_name                  = var.eventhub_name

  # PostgreSQL Logs
  enabled_log {
    category = "PostgreSQLLogs"
  }

  depends_on = [
    azurerm_postgresql_flexible_server_configuration.shared_preload_libraries,
    azurerm_postgresql_flexible_server_configuration.pgaudit_log,
    azurerm_postgresql_flexible_server_configuration.log_line_prefix
  ]
}

######
# Universal Connector Module - Can be disabled with enable_universal_connector = false
######

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
  profile_definition_name = "Azure Postgres Over Event Hub"
  udc_name                = var.postgres_server_name
  description             = "GDP Azure Postgres connector for ${var.postgres_server_name}"

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

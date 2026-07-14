#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = local.udc_name
}

output "mysql_server_name" {
  description = "Name of the MySQL server"
  value       = var.mysql_server_name
}

output "mysql_server_endpoint" {
  description = "Fully qualified domain name of the MySQL server"
  value       = data.azurerm_mysql_flexible_server.mysql.fqdn
}

output "eventhub_namespace_name" {
  description = "Name of the Event Hub namespace"
  value       = var.eventhub_namespace_name
}

output "eventhub_name" {
  description = "Name of the Event Hub"
  value       = var.eventhub_name
}

output "storage_account_name" {
  description = "Name of the storage account for checkpointing"
  value       = var.storage_account_name
}

output "azure_region" {
  description = "Azure region where resources are deployed"
  value       = local.azure_region
}

output "subscription_id" {
  description = "Azure subscription ID"
  value       = local.subscription_id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = var.resource_group_name
}

output "diagnostic_setting_name" {
  description = "Name of the diagnostic setting"
  value       = azurerm_monitor_diagnostic_setting.mysql_audit.name
}

output "diagnostic_setting_id" {
  description = "ID of the diagnostic setting"
  value       = azurerm_monitor_diagnostic_setting.mysql_audit.id
}

output "mysql_audit_configuration" {
  description = "MySQL audit configuration summary"
  value = {
    audit_log_enabled = azurerm_mysql_flexible_server_configuration.audit_log_enabled.value
    audit_log_events  = var.enable_mysql_audit_logs ? azurerm_mysql_flexible_server_configuration.audit_log_events[0].value : "N/A"
  }
}

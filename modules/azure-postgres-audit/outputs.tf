#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "profile_csv" {
  description = "Universal Connector profile CSV"
  value       = module.common_azure-eventhub-registration.profile_csv
}

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = local.udc_name
}

output "postgres_server_name" {
  description = "Name of the PostgreSQL server"
  value       = var.postgres_server_name
}

output "postgres_server_endpoint" {
  description = "Fully qualified domain name of the PostgreSQL server"
  value       = data.azurerm_postgresql_flexible_server.postgres.fqdn
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
  value       = azurerm_monitor_diagnostic_setting.postgres_audit.name
}

output "diagnostic_setting_id" {
  description = "ID of the diagnostic setting"
  value       = azurerm_monitor_diagnostic_setting.postgres_audit.id
}

output "pgaudit_configuration" {
  description = "pgAudit configuration summary"
  value = {
    shared_preload_libraries = "PGAUDIT"
    pgaudit_log              = var.pgaudit_log
    pgaudit_log_catalog      = var.pgaudit_log_catalog
    pgaudit_log_client       = var.pgaudit_log_client
    pgaudit_log_parameter    = var.pgaudit_log_parameter
    log_checkpoints          = var.log_checkpoints
    log_error_verbosity      = var.log_error_verbosity
    log_line_prefix          = var.log_line_prefix
  }
}
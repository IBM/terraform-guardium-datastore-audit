#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = module.datastore-audit_azure-postgres-audit.udc_name
}

output "postgres_server_name" {
  description = "Name of the PostgreSQL server"
  value       = module.datastore-audit_azure-postgres-audit.postgres_server_name
}

output "postgres_server_endpoint" {
  description = "Fully qualified domain name of the PostgreSQL server"
  value       = module.datastore-audit_azure-postgres-audit.postgres_server_endpoint
}

output "eventhub_namespace_name" {
  description = "Name of the Event Hub namespace"
  value       = module.datastore-audit_azure-postgres-audit.eventhub_namespace_name
}

output "eventhub_name" {
  description = "Name of the Event Hub"
  value       = module.datastore-audit_azure-postgres-audit.eventhub_name
}

output "storage_account_name" {
  description = "Name of the storage account for checkpointing"
  value       = module.datastore-audit_azure-postgres-audit.storage_account_name
}

output "azure_region" {
  description = "Azure region where resources are deployed"
  value       = module.datastore-audit_azure-postgres-audit.azure_region
}

output "subscription_id" {
  description = "Azure subscription ID"
  value       = module.datastore-audit_azure-postgres-audit.subscription_id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.datastore-audit_azure-postgres-audit.resource_group_name
}

output "diagnostic_setting_name" {
  description = "Name of the diagnostic setting"
  value       = module.datastore-audit_azure-postgres-audit.diagnostic_setting_name
}

output "pgaudit_configuration" {
  description = "Summary of pgAudit configuration"
  value       = module.datastore-audit_azure-postgres-audit.pgaudit_configuration
}
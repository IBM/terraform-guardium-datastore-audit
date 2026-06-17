#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = module.datastore-audit_azure-mysql-audit.udc_name
}

output "mysql_server_name" {
  description = "Name of the MySQL server"
  value       = module.datastore-audit_azure-mysql-audit.mysql_server_name
}

output "mysql_server_fqdn" {
  description = "Fully qualified domain name of the MySQL server"
  value       = module.datastore-audit_azure-mysql-audit.mysql_server_fqdn
}

output "eventhub_namespace_name" {
  description = "Name of the Event Hub namespace"
  value       = module.datastore-audit_azure-mysql-audit.eventhub_namespace_name
}

output "eventhub_name" {
  description = "Name of the Event Hub"
  value       = module.datastore-audit_azure-mysql-audit.eventhub_name
}

output "storage_account_name" {
  description = "Name of the storage account for checkpointing"
  value       = module.datastore-audit_azure-mysql-audit.storage_account_name
}

output "azure_region" {
  description = "Azure region where resources are deployed"
  value       = module.datastore-audit_azure-mysql-audit.azure_region
}

output "subscription_id" {
  description = "Azure subscription ID"
  value       = module.datastore-audit_azure-mysql-audit.subscription_id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.datastore-audit_azure-mysql-audit.resource_group_name
}

output "diagnostic_setting_name" {
  description = "Name of the diagnostic setting"
  value       = module.datastore-audit_azure-mysql-audit.diagnostic_setting_name
}
#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

output "profile_csv" {
  description = "Universal Connector profile CSV"
  value       = module.common_azure-sql-jdbc-registration.profile_csv
  sensitive   = true
}

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = local.udc_name
}

output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = var.sql_server_name
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = var.sql_database_name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = module.common_azure-sql-audit-settings.sql_server_fqdn
}

output "storage_account_name" {
  description = "Name of the storage account for audit logs"
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

output "server_audit_policy_id" {
  description = "ID of the server-level audit policy"
  value       = module.common_azure-sql-audit-settings.server_audit_policy_id
}

output "database_audit_policy_id" {
  description = "ID of the database-level audit policy"
  value       = module.common_azure-sql-audit-settings.database_audit_policy_id
}

output "jdbc_connection_string" {
  description = "JDBC connection string (without credentials)"
  value       = local.jdbc_connection_string
  sensitive   = false
}
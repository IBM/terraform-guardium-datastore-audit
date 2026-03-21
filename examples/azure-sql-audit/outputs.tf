#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

output "profile_csv" {
  description = "Universal Connector profile CSV"
  value       = module.datastore-audit_azure-sql-audit.profile_csv
}

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = module.datastore-audit_azure-sql-audit.udc_name
}

output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = module.datastore-audit_azure-sql-audit.sql_server_name
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = module.datastore-audit_azure-sql-audit.sql_database_name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = module.datastore-audit_azure-sql-audit.sql_server_fqdn
}

output "storage_account_name" {
  description = "Name of the storage account for audit logs"
  value       = module.datastore-audit_azure-sql-audit.storage_account_name
}

output "azure_region" {
  description = "Azure region where resources are deployed"
  value       = module.datastore-audit_azure-sql-audit.azure_region
}

output "subscription_id" {
  description = "Azure subscription ID"
  value       = module.datastore-audit_azure-sql-audit.subscription_id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.datastore-audit_azure-sql-audit.resource_group_name
}

output "server_audit_policy_id" {
  description = "ID of the server-level audit policy"
  value       = module.datastore-audit_azure-sql-audit.server_audit_policy_id
}

output "database_audit_policy_id" {
  description = "ID of the database-level audit policy"
  value       = module.datastore-audit_azure-sql-audit.database_audit_policy_id
}

output "jdbc_connection_string" {
  description = "JDBC connection string (without credentials)"
  value       = module.datastore-audit_azure-sql-audit.jdbc_connection_string
  sensitive   = false
}
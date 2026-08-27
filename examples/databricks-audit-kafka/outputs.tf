#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "profile_csv" {
  description = "Universal Connector profile CSV"
  value       = module.datastore-audit_databricks-audit-kafka.profile_csv
  sensitive   = true
}

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = module.datastore-audit_databricks-audit-kafka.udc_name
}

output "databricks_workspace_name" {
  description = "Name of the monitored Databricks workspace (Unity Catalog enabled)"
  value       = module.datastore-audit_databricks-audit-kafka.databricks_workspace_name
}

output "eventhub_namespace_name" {
  description = "Name of the Event Hub namespace"
  value       = module.datastore-audit_databricks-audit-kafka.eventhub_namespace_name
}

output "eventhub_name" {
  description = "Name of the Event Hub"
  value       = module.datastore-audit_databricks-audit-kafka.eventhub_name
}

output "diagnostic_setting_name" {
  description = "Name of the Azure Monitor diagnostic setting"
  value       = module.datastore-audit_databricks-audit-kafka.diagnostic_setting_name
}

output "subscription_id" {
  description = "Azure subscription ID"
  value       = module.datastore-audit_databricks-audit-kafka.subscription_id
}

output "uc_version" {
  description = "Databricks UC version in use"
  value       = module.datastore-audit_databricks-audit-kafka.uc_version
}

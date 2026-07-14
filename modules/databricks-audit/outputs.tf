#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "profile_csv" {
  description = "Universal Connector profile CSV"
  value       = module.common_databricks-eventhub-registration.profile_csv
  sensitive   = true
}

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = local.udc_name
}

output "databricks_workspace_name" {
  description = "Name of the monitored Databricks workspace"
  value       = var.databricks_workspace_name
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

output "diagnostic_setting_name" {
  description = "Name of the Azure Monitor diagnostic setting"
  value       = var.diagnostic_setting_name
}

output "subscription_id" {
  description = "Azure subscription ID"
  value       = local.subscription_id
}

output "uc_version" {
  description = "Databricks UC version in use (uc1 or uc2)"
  value       = var.uc_version
}

#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

output "profile_csv" {
  description = "Universal Connector profile CSV"
  value       = module.common_azure-cosmos-eventhub-registration.profile_csv
}

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = local.udc_name
}

output "cosmos_account_name" {
  description = "Name of the Cosmos DB account"
  value       = var.cosmos_account_name
}

output "cosmos_account_endpoint" {
  description = "Endpoint of the Cosmos DB account"
  value       = module.common_azure-cosmos-diagnostic-settings.cosmos_account_endpoint
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
  value       = module.common_azure-cosmos-diagnostic-settings.diagnostic_setting_name
}

output "diagnostic_setting_id" {
  description = "ID of the diagnostic setting"
  value       = module.common_azure-cosmos-diagnostic-settings.diagnostic_setting_id
}
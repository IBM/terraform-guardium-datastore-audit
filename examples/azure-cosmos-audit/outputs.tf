#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Azure Cosmos DB Audit Example Outputs

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = module.datastore-audit_azure-cosmos-audit.udc_name
}

output "cosmos_account_name" {
  description = "Name of the Cosmos DB account"
  value       = module.datastore-audit_azure-cosmos-audit.cosmos_account_name
}

output "cosmos_account_endpoint" {
  description = "Endpoint of the Cosmos DB account"
  value       = module.datastore-audit_azure-cosmos-audit.cosmos_account_endpoint
}

output "eventhub_namespace_name" {
  description = "Name of the Event Hub namespace"
  value       = module.datastore-audit_azure-cosmos-audit.eventhub_namespace_name
}

output "eventhub_name" {
  description = "Name of the Event Hub"
  value       = module.datastore-audit_azure-cosmos-audit.eventhub_name
}

output "storage_account_name" {
  description = "Name of the storage account for checkpointing"
  value       = module.datastore-audit_azure-cosmos-audit.storage_account_name
}

output "azure_region" {
  description = "Azure region where resources are deployed"
  value       = module.datastore-audit_azure-cosmos-audit.azure_region
}

output "subscription_id" {
  description = "Azure subscription ID"
  value       = module.datastore-audit_azure-cosmos-audit.subscription_id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.datastore-audit_azure-cosmos-audit.resource_group_name
}

output "diagnostic_setting_name" {
  description = "Name of the diagnostic setting"
  value       = module.datastore-audit_azure-cosmos-audit.diagnostic_setting_name
}

output "diagnostic_setting_id" {
  description = "ID of the diagnostic setting"
  value       = module.datastore-audit_azure-cosmos-audit.diagnostic_setting_id
}
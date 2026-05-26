#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

locals {
  udc_name        = format("%s-%s-%s", var.azure_region, var.cosmos_account_name, local.subscription_id)
  subscription_id = data.azurerm_client_config.current.subscription_id
  azure_region    = var.azure_region
}

data "azurerm_client_config" "current" {}

# Get Event Hub authorization rule for connection string
data "azurerm_eventhub_namespace_authorization_rule" "eventhub_auth" {
  name                = var.eventhub_authorization_rule_name
  namespace_name      = var.eventhub_namespace_name
  resource_group_name = var.resource_group_name
}

# Get Storage Account details for connection string
data "azurerm_storage_account" "checkpoint" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Call diagnostic settings common module
module "common_azure-cosmos-diagnostic-settings" {
  source = "../../../terraform-guardium-common/modules/azure-cosmos-diagnostic-settings"

  cosmos_account_name              = var.cosmos_account_name
  resource_group_name              = var.resource_group_name
  eventhub_namespace_name          = var.eventhub_namespace_name
  eventhub_name                    = var.eventhub_name
  storage_account_name             = var.storage_account_name
  eventhub_authorization_rule_name = var.eventhub_authorization_rule_name
  diagnostic_setting_name          = var.diagnostic_setting_name
  enable_data_plane_logs           = var.enable_data_plane_logs
  enable_query_runtime_logs        = var.enable_query_runtime_logs
  enable_control_plane_logs        = var.enable_control_plane_logs
  enable_partition_key_logs        = var.enable_partition_key_logs
  enable_partition_ru_logs         = var.enable_partition_ru_logs
}

//////
// Universal Connector Module - Can be disabled with enable_universal_connector = false
//////

locals {
  # Build Event Hub connection string
  event_hub_connection = format("Endpoint=sb://%s.servicebus.windows.net/;SharedAccessKeyName=%s;SharedAccessKey=%s;EntityPath=%s",
    var.eventhub_namespace_name,
    var.eventhub_authorization_rule_name,
    data.azurerm_eventhub_namespace_authorization_rule.eventhub_auth.primary_key,
    var.eventhub_name
  )

  # Build Storage connection string
  storage_connection = format("DefaultEndpointsProtocol=https;AccountName=%s;AccountKey=%s;EndpointSuffix=core.windows.net",
    var.storage_account_name,
    data.azurerm_storage_account.checkpoint.primary_access_key
  )
}

module "common_azure-cosmos-eventhub-registration" {
  source = "../../../terraform-guardium-common/modules/azure-cosmos-eventhub-registration"

  # Azure Configuration
  azure_region          = var.azure_region
  azure_subscription_id = local.subscription_id

  # Event Hub Configuration
  event_hub_connections = local.event_hub_connection
  storage_connection    = local.storage_connection
  consumer_group        = var.consumer_group

  # Guardium Configuration
  udc_name                   = var.cosmos_account_name
  gdp_client_id              = var.gdp_client_id
  gdp_client_secret          = var.gdp_client_secret
  gdp_server                 = var.gdp_server
  gdp_port                   = var.gdp_port
  gdp_username               = var.gdp_username
  gdp_password               = var.gdp_password
  gdp_mu_host                = var.gdp_mu_host
  enable_universal_connector = var.enable_universal_connector
  csv_start_position         = var.csv_start_position
}
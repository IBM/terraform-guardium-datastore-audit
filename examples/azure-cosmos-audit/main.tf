#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

provider "azurerm" {
  features {}
}

module "datastore-audit_azure-cosmos-audit" {
  source = "../../modules/azure-cosmos-audit"

  # Azure Configuration
  azure_region        = var.azure_region
  resource_group_name = var.resource_group_name
  cosmos_account_name = var.cosmos_account_name

  # Event Hub Configuration
  eventhub_namespace_name          = var.eventhub_namespace_name
  eventhub_name                    = var.eventhub_name
  eventhub_authorization_rule_name = var.eventhub_authorization_rule_name
  storage_account_name             = var.storage_account_name
  consumer_group                   = var.consumer_group

  # Diagnostic Settings Configuration
  diagnostic_setting_name   = var.diagnostic_setting_name
  enable_data_plane_logs    = var.enable_data_plane_logs
  enable_query_runtime_logs = var.enable_query_runtime_logs
  enable_control_plane_logs = var.enable_control_plane_logs
  enable_partition_key_logs = var.enable_partition_key_logs
  enable_partition_ru_logs  = var.enable_partition_ru_logs

  # Guardium Configuration
  gdp_client_id        = var.gdp_client_id
  gdp_client_secret    = var.gdp_client_secret
  gdp_server           = var.gdp_server
  gdp_port             = var.gdp_port
  gdp_username         = var.gdp_username
  gdp_password         = var.gdp_password
  gdp_mu_host          = var.gdp_mu_host

  # Universal Connector Configuration
  enable_universal_connector = var.enable_universal_connector
  csv_start_position         = var.csv_start_position
  csv_interval               = var.csv_interval
  codec_pattern              = var.codec_pattern
  csv_event_filter           = var.csv_event_filter

  # Tags
  tags = var.tags
}
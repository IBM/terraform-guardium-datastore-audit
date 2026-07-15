#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

provider "azurerm" {
  features {}
}

module "datastore-audit_databricks-audit-kafka" {
  source = "../../modules/databricks-audit"

  # Azure Configuration
  azure_region                     = var.azure_region
  resource_group_name              = var.resource_group_name
  databricks_workspace_name        = var.databricks_workspace_name
  databricks_workspace_resource_id = var.databricks_workspace_resource_id
  azure_enrollment_id              = var.azure_enrollment_id

  # UC Version - UC 2.0: Unity Catalog auditing (adds unityCatalog log category)
  uc_version = "uc2"

  # Event Hub Configuration
  eventhub_namespace_name          = var.eventhub_namespace_name
  eventhub_name                    = var.eventhub_name
  eventhub_authorization_rule_name           = var.eventhub_authorization_rule_name
  eventhub_namespace_authorization_rule_name = var.eventhub_namespace_authorization_rule_name
  storage_account_name             = var.storage_account_name
  consumer_group                   = var.consumer_group
  diagnostic_setting_name          = var.diagnostic_setting_name

  # Guardium Configuration
  gdp_client_id     = var.gdp_client_id
  gdp_client_secret = var.gdp_client_secret
  gdp_server        = var.gdp_server
  gdp_port          = var.gdp_port
  gdp_username      = var.gdp_username
  gdp_password      = var.gdp_password
  gdp_mu_host       = var.gdp_mu_host

  # Universal Connector Configuration
  udc_name                   = var.udc_name
  udc_credential             = var.udc_credential
  enable_universal_connector = var.enable_universal_connector
  csv_start_position         = var.csv_start_position
  udc_description            = var.udc_description

  # Event Hub Advanced Configuration
  config_mode     = var.config_mode
  threads         = var.threads
  decorate_events = var.decorate_events

  # UC 2.0-specific Configuration
  gdp_cluster_name         = var.gdp_cluster_name
  mu_count                 = var.mu_count
  use_elb                  = var.use_elb
  eventhub_partition_count = var.eventhub_partition_count
  start_time               = var.start_time
  nodata_threshold_min     = var.nodata_threshold_min

  # Tags
  tags = var.tags
}

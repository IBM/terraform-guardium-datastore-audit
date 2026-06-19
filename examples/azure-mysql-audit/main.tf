#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

provider "azurerm" {
  features {}
}

module "datastore-audit_azure-mysql-audit" {
  source = "../../modules/azure-mysql-audit"

  # Azure Configuration
  azure_region        = var.azure_region
  resource_group_name = var.resource_group_name
  mysql_server_name   = var.mysql_server_name

  # Event Hub Configuration
  eventhub_namespace_name          = var.eventhub_namespace_name
  eventhub_name                    = var.eventhub_name
  eventhub_authorization_rule_name = var.eventhub_authorization_rule_name
  storage_account_name             = var.storage_account_name
  consumer_group                   = var.consumer_group

  # Diagnostic Settings Configuration
  diagnostic_setting_name = var.diagnostic_setting_name
  enable_mysql_audit_logs = var.enable_mysql_audit_logs
  enable_slow_query_logs  = var.enable_slow_query_logs

  # Guardium Configuration
  gdp_client_id     = var.gdp_client_id
  gdp_client_secret = var.gdp_client_secret
  gdp_server        = var.gdp_server
  gdp_port          = var.gdp_port
  gdp_username      = var.gdp_username
  gdp_password      = var.gdp_password
  gdp_mu_host       = var.gdp_mu_host

  # Universal Connector Configuration
  enable_universal_connector = var.enable_universal_connector
  initial_position           = var.initial_position
  config_mode                = var.config_mode
  threads                    = var.threads
  decorate_events            = var.decorate_events

  # Tags
  tags = var.tags
}
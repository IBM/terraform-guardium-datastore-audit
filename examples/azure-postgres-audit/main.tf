#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

provider "azurerm" {
  features {}
}

module "datastore-audit_azure-postgres-audit" {
  source = "../../modules/azure-postgres-audit"

  # Azure Configuration
  azure_region         = var.azure_region
  azure_enrollment_id  = var.azure_enrollment_id
  resource_group_name  = var.resource_group_name
  postgres_server_name = var.postgres_server_name

  # Event Hub Configuration
  eventhub_namespace_name          = var.eventhub_namespace_name
  eventhub_name                    = var.eventhub_name
  eventhub_authorization_rule_name = var.eventhub_authorization_rule_name
  eventhub_sas_policy_name         = var.eventhub_sas_policy_name
  storage_account_name             = var.storage_account_name
  consumer_group                   = var.consumer_group
  firewall_rules                   = var.firewall_rules

  # Diagnostic Settings Configuration
  diagnostic_setting_name = var.diagnostic_setting_name

  # pgAudit Configuration
  pgaudit_log           = var.pgaudit_log
  pgaudit_log_catalog   = var.pgaudit_log_catalog
  pgaudit_log_client    = var.pgaudit_log_client
  pgaudit_log_parameter = var.pgaudit_log_parameter
  log_checkpoints       = var.log_checkpoints
  log_error_verbosity   = var.log_error_verbosity
  log_line_prefix       = var.log_line_prefix

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
}
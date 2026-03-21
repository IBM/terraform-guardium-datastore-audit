#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

provider "azurerm" {
  features {}
}

provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}

module "datastore-audit_azure-sql-audit" {
  source = "../../modules/azure-sql-audit"

  # Azure Configuration
  azure_region         = var.azure_region
  resource_group_name  = var.resource_group_name
  sql_server_name      = var.sql_server_name
  sql_database_name    = var.sql_database_name
  storage_account_name = var.storage_account_name
  audit_container_name = var.audit_container_name
  retention_in_days    = var.retention_in_days

  # JDBC Configuration
  jdbc_user            = var.jdbc_user
  jdbc_password        = var.jdbc_password
  tracking_table_name  = var.tracking_table_name
  enrollment_id        = var.enrollment_id

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
  csv_start_position         = var.csv_start_position
  csv_interval               = var.csv_interval
  codec_pattern              = var.codec_pattern
  csv_event_filter           = var.csv_event_filter

  # Tags
  tags = var.tags
}
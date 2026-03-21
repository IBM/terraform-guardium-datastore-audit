#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

locals {
  udc_name        = format("%s-%s-%s", var.azure_region, var.sql_server_name, local.subscription_id)
  subscription_id = data.azurerm_client_config.current.subscription_id
  azure_region    = var.azure_region
}

data "azurerm_client_config" "current" {}

# Get SQL Server details
data "azurerm_mssql_server" "sql_server" {
  name                = var.sql_server_name
  resource_group_name = var.resource_group_name
}

# Get Storage Account details for audit logs
data "azurerm_storage_account" "audit" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Call audit settings common module
module "common_azure-sql-audit-settings" {
  source = "../../../terraform-guardium-common/modules/azure-sql-audit-settings"

  sql_server_name       = var.sql_server_name
  sql_database_name     = var.sql_database_name
  resource_group_name   = var.resource_group_name
  storage_account_name  = var.storage_account_name
  audit_retention_days  = var.retention_in_days
}

//////
// Universal Connector Module - Can be disabled with enable_universal_connector = false
//////

locals {
  # Build JDBC connection string
  jdbc_connection_string = format("jdbc:sqlserver://%s:1433;database=%s;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;",
    data.azurerm_mssql_server.sql_server.fully_qualified_domain_name,
    var.sql_database_name
  )

  # Build SQL query for audit log retrieval
  audit_log_query = format(
    "SELECT * FROM sys.fn_get_audit_file('%s', default, default) WHERE event_time > (SELECT ISNULL(MAX(updatedeventtime), '1900-01-01') FROM %s)",
    format("https://%s.blob.core.windows.net/%s/*", var.storage_account_name, var.audit_container_name),
    var.tracking_table_name
  )
}

module "common_azure-sql-jdbc-registration" {
  source = "../../../terraform-guardium-common/modules/azure-sql-jdbc-registration"

  # Azure Configuration
  azure_region          = var.azure_region
  azure_subscription_id = local.subscription_id
  enrollment_id         = var.enrollment_id

  # JDBC Configuration
  jdbc_connection_string = local.jdbc_connection_string
  jdbc_user              = var.jdbc_user
  jdbc_password          = var.jdbc_password
  statement              = local.audit_log_query

  # Guardium Configuration
  udc_name                   = var.sql_server_name
  gdp_client_id              = var.gdp_client_id
  gdp_client_secret          = var.gdp_client_secret
  gdp_server                 = var.gdp_server
  gdp_port                   = var.gdp_port
  gdp_username               = var.gdp_username
  gdp_password               = var.gdp_password
  gdp_mu_host                = var.gdp_mu_host
  enable_universal_connector = var.enable_universal_connector
}
#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

locals {
  udc_name        = format("%s-azuresql-%s", var.azure_region, local.subscription_id)
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

  # Split SQL query into three parts for Guardium UI format
  statement_select = "event_time,succeeded,session_id,database_name,client_ip,server_principal_name,application_name,statement,server_instance_name,host_name,DATEDIFF_BIG(ns, '1970-01-01 00:00:00.00000', event_time) AS updatedeventtime,additional_information"
  
  statement_from = format("sys.fn_get_audit_file('https://%s.blob.core.windows.net/%s/%s/%s', DEFAULT, DEFAULT)",
    var.storage_account_name,
    var.audit_container_name,
    var.sql_server_name,
    var.sql_database_name
  )
  
  statement_where = "action_id='BCM' and statement not like '%xproc%' and statement not like '%SPID%' and statement not like '%DEADLOCK_PRIORITY%' and application_name not like '%Microsoft SQL Server Management Studio - Transact-SQL IntelliSense%' and DATEDIFF_BIG(ns, '1970-01-01 00:00:00.00000', event_time) > :sql_last_value"
}

module "common_azure-sql-jdbc-registration" {
  source = "../../../terraform-guardium-common/modules/azure-sql-jdbc-registration"

  # Azure Configuration
  azure_region          = var.azure_region
  azure_subscription_id = local.subscription_id
  enrollment_id         = var.enrollment_id

  # JDBC Configuration
  jdbc_connection_string = local.jdbc_connection_string
  credential_name        = var.credential_name
  jdbc_driver_library    = var.jdbc_driver_library
  statement_select       = local.statement_select
  statement_from         = local.statement_from
  statement_where        = local.statement_where

  # Guardium Configuration
  udc_name                   = "azuresql"
  gdp_client_id              = var.gdp_client_id
  gdp_client_secret          = var.gdp_client_secret
  gdp_server                 = var.gdp_server
  gdp_port                   = var.gdp_port
  gdp_username               = var.gdp_username
  gdp_password               = var.gdp_password
  gdp_mu_host                = var.gdp_mu_host
  enable_universal_connector = var.enable_universal_connector
}
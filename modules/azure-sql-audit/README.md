# Azure SQL Audit Module

This module configures Azure SQL Database auditing and integrates with IBM Guardium Data Protection using the JDBC Universal Connector.

## Architecture

The module orchestrates two common modules:
1. **azure-sql-audit-settings**: Configures server-level and database-level auditing to Azure Storage Account
2. **azure-sql-jdbc-registration**: Registers JDBC connection with Guardium Universal Connector

## Features

- Server-level and database-level audit policy configuration
- Audit logs stored in Azure Storage Account
- JDBC-based pull model for audit log retrieval
- Automatic UC profile deployment to Guardium CM and MU
- Incremental tracking using `updatedeventtime` column
- Multi-tenant support via enrollment ID

## Usage

```hcl
module "azure_sql_audit" {
  source = "../../modules/azure-sql-audit"

  # Azure Configuration
  azure_region         = "eastus"
  resource_group_name  = "my-resource-group"
  sql_server_name      = "my-sql-server"
  sql_database_name    = "my-database"
  storage_account_name = "mysqlauditstorage"
  
  # JDBC Configuration
  jdbc_user     = "sqladmin"
  jdbc_password = var.sql_admin_password
  enrollment_id = "12345678"
  
  # Guardium Configuration
  gdp_client_id     = var.gdp_client_id
  gdp_client_secret = var.gdp_client_secret
  gdp_server        = "guardium-cm.example.com"
  gdp_username      = var.gdp_username
  gdp_password      = var.gdp_password
  gdp_mu_host       = "guardium-mu1.example.com,guardium-mu2.example.com"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |
| guardium | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| azure_region | Azure region where resources are deployed | `string` | `"eastus"` | no |
| resource_group_name | Name of the Azure resource group | `string` | n/a | yes |
| sql_server_name | Name of the Azure SQL Server | `string` | n/a | yes |
| sql_database_name | Name of the Azure SQL Database | `string` | n/a | yes |
| storage_account_name | Name of the storage account for audit logs | `string` | n/a | yes |
| audit_container_name | Name of the storage container for audit logs | `string` | `"sqldbauditlogs"` | no |
| retention_in_days | Number of days to retain audit logs | `number` | `90` | no |
| jdbc_user | SQL Server admin username | `string` | n/a | yes |
| jdbc_password | SQL Server admin password | `string` | n/a | yes |
| tracking_table_name | Name of the tracking table | `string` | `"guardium_audit_tracking"` | no |
| enrollment_id | Azure enrollment ID | `string` | `""` | no |
| gdp_client_id | Guardium OAuth client ID | `string` | n/a | yes |
| gdp_client_secret | Guardium OAuth client secret | `string` | n/a | yes |
| gdp_server | Guardium Central Manager hostname | `string` | n/a | yes |
| gdp_port | Guardium Central Manager port | `string` | `"8443"` | no |
| gdp_username | Guardium Web UI username | `string` | n/a | yes |
| gdp_password | Guardium Web UI password | `string` | n/a | yes |
| gdp_mu_host | Comma-separated list of Managed Units | `string` | n/a | yes |
| enable_universal_connector | Enable/disable UC module | `bool` | `true` | no |
| csv_start_position | Start position for UDC | `string` | `"end"` | no |
| csv_interval | Polling interval in seconds | `string` | `"60"` | no |

## Outputs

| Name | Description |
|------|-------------|
| profile_csv | Universal Connector profile CSV |
| udc_name | Name of the Universal Connector |
| sql_server_name | Name of the SQL Server |
| sql_database_name | Name of the SQL Database |
| sql_server_fqdn | Fully qualified domain name of SQL Server |
| storage_account_name | Name of the storage account |
| azure_region | Azure region |
| subscription_id | Azure subscription ID |
| resource_group_name | Name of the resource group |
| server_audit_policy_id | ID of server-level audit policy |
| database_audit_policy_id | ID of database-level audit policy |
| jdbc_connection_string | JDBC connection string |

## How It Works

1. **Audit Configuration**: Configures server-level and database-level auditing policies to send audit logs to Azure Storage Account
2. **JDBC Connection**: UC connects to SQL Server using JDBC and queries audit logs using `sys.fn_get_audit_file()`
3. **Incremental Tracking**: Uses `updatedeventtime` column to track processed records
4. **Profile Deployment**: Automatically deploys UC profile to Guardium CM and specified MUs

## Prerequisites

- Azure SQL Server and Database already deployed
- Azure Storage Account for audit logs
- SQL Server admin credentials
- Guardium Central Manager with OAuth client registered
- Network connectivity from Guardium to Azure SQL Server

## Notes

- The module uses JDBC pull model (different from Azure Cosmos DB's Event Hub push model)
- Audit logs are queried directly from Storage Account using `sys.fn_get_audit_file()`
- Polling interval defaults to 60 seconds (configurable)
- Enrollment ID is optional but recommended for multi-tenant environments

## Related Modules

- [azure-sql-audit-settings](../../../terraform-guardium-common/modules/azure-sql-audit-settings)
- [azure-sql-jdbc-registration](../../../terraform-guardium-common/modules/azure-sql-jdbc-registration)

## References

- [Azure SQL Database Auditing](https://learn.microsoft.com/en-us/azure/azure-sql/database/auditing-overview)
- [sys.fn_get_audit_file](https://learn.microsoft.com/en-us/sql/relational-databases/system-functions/sys-fn-get-audit-file-transact-sql)
- [IBM Guardium Universal Connector](https://www.ibm.com/docs/en/guardium)
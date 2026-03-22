# Azure SQL Database Audit Configuration

This module configures audit logging for Azure SQL Database with IBM Guardium Data Protection. It enables server-level auditing to stream audit logs to Azure Storage Account and configures Guardium Universal Connector for JDBC-based log collection.

**Supported Versions:** This module requires IBM Guardium Data Protection (GDP) version **12.2.1 and above**.

## Prerequisites

Before using this module, you need to:

1. Have an existing Azure SQL Server and Database
2. Have Storage Account created for audit log storage
3. Have Guardium set up with appropriate credentials
4. Have JDBC credential configured in Guardium Universal Connector
5. Have JDBC driver (mssql-jdbc-7.4.1.jre8.jar) uploaded to Guardium

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | ~> 3.0 |
| guardium-data-protection | >= 1.0.0 |

## Features

- Configures Azure SQL Database server-level auditing policy
- Stores audit logs in Azure Storage Account as .xel files
- Supports multiple audit action groups:
  - SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP
  - FAILED_DATABASE_AUTHENTICATION_GROUP
  - BATCH_COMPLETED_GROUP
- Integrates with Guardium for audit data collection via JDBC
- Automatic Universal Connector profile deployment
- Incremental tracking using `updatedeventtime` column

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│              Azure SQL Database                             │
│                                                             │
│  • Successful Authentication                                │
│  • Failed Authentication                                    │
│  • Batch Completed (SQL Statements)                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ Server-Level Auditing
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│              Azure Storage Account                          │
│                                                             │
│  • Container: sqldbauditlogs                                │
│  • Format: .xel files                                       │
│  • Path: /server/master/SqlDbAuditing_ServerAudit          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ JDBC Query (sys.fn_get_audit_file)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│         Guardium Universal Connector (UC)                   │
│                                                             │
│  • Queries audit logs via JDBC                              │
│  • Parses and normalizes audit data                         │
│  • Applies security policies                                │
│  • Forwards to Guardium Data Protection                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ Processed Audit Data
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│         Guardium Data Protection (GDP)                      │
│                                                             │
│  • Security monitoring and threat detection                 │
│  • Compliance reporting and auditing                        │
│  • Policy enforcement and alerting                          │
│  • Activity analysis and forensics                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Usage

### Basic Example

```hcl
module "sql_audit" {
  source = "IBM/datastore-audit/guardium//modules/azure-sql-audit"

  # Azure Configuration
  azure_region         = "eastus"
  resource_group_name  = "my-resource-group"
  sql_server_name      = "my-sql-server"
  sql_database_name    = "my-database"
  storage_account_name = "mysqlauditstorage"
  
  # Guardium Configuration
  gdp_server             = "guardium.example.com"
  gdp_port               = "8443"
  gdp_username           = "admin"
  gdp_password           = "password"
  gdp_client_id          = "client1"
  gdp_client_secret      = "client-secret"
  gdp_mu_host            = "guardium-mu.example.com"
  
  # JDBC Configuration
  credential_name      = "azure-sql-jdbc-cred"
  jdbc_driver_library  = "mssql-jdbc-7.4.1.jre8.jar"
  enrollment_id        = "123456789"
  
  tags = {
    Environment = "production"
    Project     = "data-security"
  }
}
```

### Advanced Example with Custom Configuration

```hcl
module "sql_audit" {
  source = "IBM/datastore-audit/guardium//modules/azure-sql-audit"

  # Azure Configuration
  azure_region         = "eastus"
  resource_group_name  = "my-resource-group"
  sql_server_name      = "my-sql-server"
  sql_database_name    = "my-database"
  storage_account_name = "mysqlauditstorage"
  audit_container_name = "sqldbauditlogs"
  retention_in_days    = 90
  
  # Guardium Configuration
  gdp_server             = "guardium.example.com"
  gdp_port               = "8443"
  gdp_username           = "admin"
  gdp_password           = "password"
  gdp_client_id          = "client1"
  gdp_client_secret      = "client-secret"
  gdp_mu_host            = "guardium-mu1.example.com,guardium-mu2.example.com"
  
  # JDBC Configuration
  credential_name      = "azure-sql-jdbc-cred"
  jdbc_driver_library  = "mssql-jdbc-7.4.1.jre8.jar"
  enrollment_id        = "123456789"
  
  # Universal Connector Configuration
  csv_start_position   = "end"
  csv_interval         = "60"
  
  tags = {
    Environment = "production"
    Project     = "data-security"
  }
}
```

## Provider Configuration

This module requires both the Azure provider and the Guardium Data Protection provider.
The providers are configured automatically using the variables you provide:

```hcl
provider "azurerm" {
  features {}
}

provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}
```

Make sure your Terraform environment has access to the Guardium Data Protection provider, which is sourced from:
```
na.artifactory.swg-devops.com/ibm/guardium-data-protection
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| azure_region | Azure region where resources are deployed | `string` | `"eastus"` | no |
| resource_group_name | Name of the Azure resource group | `string` | n/a | yes |
| sql_server_name | Name of the SQL Server | `string` | n/a | yes |
| sql_database_name | Name of the SQL Database | `string` | n/a | yes |
| storage_account_name | Name of the storage account for audit logs | `string` | n/a | yes |
| audit_container_name | Name of the storage container for audit logs | `string` | `"sqldbauditlogs"` | no |
| retention_in_days | Number of days to retain audit logs | `number` | `90` | no |
| credential_name | Name of JDBC credential in Guardium | `string` | `"azure-sql-jdbc-cred"` | no |
| jdbc_driver_library | Name of JDBC driver JAR file in Guardium | `string` | `"mssql-jdbc-7.4.1.jre8.jar"` | no |
| enrollment_id | Azure enrollment ID for multi-tenant support | `string` | `"123456789"` | no |
| gdp_server | Hostname/IP of Guardium Central Manager | `string` | n/a | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"` | no |
| gdp_username | Guardium Web UI username | `string` | n/a | yes |
| gdp_password | Guardium Web UI password | `string` | n/a | yes |
| gdp_client_id | OAuth client ID | `string` | n/a | yes |
| gdp_client_secret | OAuth client secret | `string` | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units | `string` | n/a | yes |
| enable_universal_connector | Enable Universal Connector module | `bool` | `true` | no |
| csv_start_position | Start position for UDC (beginning or end) | `string` | `"end"` | no |
| csv_interval | Polling interval for UDC in seconds | `string` | `"60"` | no |
| csv_event_filter | UDC Event filters | `string` | `""` | no |
| codec_pattern | Codec pattern for the Universal Connector | `string` | `""` | no |
| tags | Map of tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| profile_csv | Universal Connector profile CSV |
| udc_name | Name of the Universal Connector |
| sql_server_name | Name of the SQL Server |
| sql_database_name | Name of the SQL Database |
| sql_server_fqdn | Fully qualified domain name of SQL Server |
| storage_account_name | Name of the storage account |
| azure_region | Azure region where resources are deployed |
| subscription_id | Azure subscription ID |
| resource_group_name | Name of the resource group |
| jdbc_connection_string | JDBC connection string (without credentials) |

## Audit Action Groups

### SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP
Captures successful user authentication events:
- User login events
- Session establishment
- Authentication method used

### FAILED_DATABASE_AUTHENTICATION_GROUP
Captures failed authentication attempts:
- Failed login attempts
- Invalid credentials
- Security threat detection

### BATCH_COMPLETED_GROUP
Captures SQL statement executions:
- SELECT, INSERT, UPDATE, DELETE operations
- Stored procedure executions
- DDL statements (CREATE, ALTER, DROP)
- Transaction control statements

## JDBC Query Details

The module uses `sys.fn_get_audit_file()` to query audit logs from Storage Account:

```sql
SELECT event_time, succeeded, session_id, database_name, client_ip, 
       server_principal_name, application_name, statement, 
       server_instance_name, host_name,
       DATEDIFF_BIG(ns, '1970-01-01 00:00:00.00000', event_time) AS updatedeventtime,
       additional_information
FROM sys.fn_get_audit_file(
  'https://<storage-account>.blob.core.windows.net/<container>/<server>/master/SqlDbAuditing_ServerAudit',
  DEFAULT,
  DEFAULT
)
WHERE action_id='BCM' 
  AND DATEDIFF_BIG(ns, '1970-01-01 00:00:00.00000', event_time) > :sql_last_value
```

**Key Features:**
- **Incremental Tracking**: Uses `updatedeventtime` to track processed records
- **Server-Level Path**: Queries from `/master/SqlDbAuditing_ServerAudit` for reliable event collection
- **Automatic Subdirectory Search**: Omits date folder to allow Azure SQL to search all subdirectories
- **Filtered Events**: Filters out system commands and internal operations

## Security Considerations

- **Credentials Management**: Store sensitive credentials securely using Terraform variables or secret management solutions
- **State File Security**: Ensure Terraform state files are encrypted and stored securely
- **Network Security**: Configure firewall rules to allow Guardium IP addresses
- **Encryption**: Enable encryption for Storage Account and data in transit
- **Access Control**: Implement proper access controls for Guardium and Azure resources
- **JDBC Security**: Use SSL/TLS for JDBC connections

## Troubleshooting

### Common Issues

1. **Audit Logs Not Appearing**:
   - Verify server-level auditing policy is enabled
   - Check Storage Account permissions and access keys
   - Ensure `log_monitoring_enabled = false` (audit data must go to Storage Account, not Azure Monitor)
   - Review audit policy configuration in Azure Portal

2. **Universal Connector Not Processing Logs**:
   - Verify JDBC credential is correctly configured in Guardium
   - Check network connectivity between Guardium and Azure SQL Server
   - Review Universal Connector logs in Guardium UI
   - Verify JDBC driver is uploaded to Guardium

3. **Authentication Errors**:
   - Verify Guardium OAuth client credentials
   - Check Guardium user has appropriate permissions
   - Ensure OAuth client is properly registered via `grdapi register_oauth_client`
   - Verify JDBC credential matches SQL Server admin credentials

4. **Missing Audit Events**:
   - Check audit action groups are properly configured
   - Verify firewall rules allow Guardium IP addresses
   - Review Storage Account audit container for .xel files
   - Check JDBC query path matches actual audit file location

## Examples

See the [examples](../../examples/azure-sql-audit) directory for complete working examples.

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](../../LICENSE) file for details.

```text
#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#
```

## Additional Resources

- [IBM Guardium Data Protection Documentation](https://www.ibm.com/docs/en/guardium)
- [Guardium Universal Connector Guide](https://www.ibm.com/docs/en/guardium/12.2?topic=connectors-universal-connector)
- [Azure SQL Database Auditing](https://learn.microsoft.com/en-us/azure/azure-sql/database/auditing-overview)
- [sys.fn_get_audit_file Function](https://learn.microsoft.com/en-us/sql/relational-databases/system-functions/sys-fn-get-audit-file-transact-sql)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
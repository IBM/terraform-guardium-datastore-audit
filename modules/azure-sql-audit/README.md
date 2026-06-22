# Azure SQL Database Audit Configuration

This module configures audit logging for Azure SQL Database with IBM Guardium Data Protection. It enables server-level auditing to stream audit logs to Azure Storage Account and configures log collection via JDBC.

**Supported Versions:** This module requires IBM Guardium Data Protection (GDP) version **12.2.1 and above**.

## Prerequisites

Before using this module, you need to:

1. Have an existing Azure SQL Server and Database
2. Have Guardium set up with appropriate credentials
3. Have JDBC credential configured in Guardium
4. Have JDBC driver (mssql-jdbc-7.4.1.jre8.jar) uploaded to Guardium

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | ~> 3.0 |
| guardium-data-protection | >= 1.0.0 |

## Features

- Configures Azure SQL Database server-level auditing policy
- Enables audit action groups for authentication and batch operations
- Stores audit logs in Azure Storage Account
- Integrates with Guardium for audit data collection via JDBC
- Queries audit logs using `sys.fn_get_audit_file()` function

## Usage

### Using a tfvars File

Create a `defaults.tfvars` file with your configuration. See [terraform.tfvars.example](./terraform.tfvars.example) for an example with available options and detailed comments.

Then run:

```bash
# Plan the changes
terraform plan -var-file=defaults.tfvars

# Apply the changes
terraform apply -var-file=defaults.tfvars
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

## Module Dependencies

This module uses the following internal modules:

1. `azure-sql-audit-settings` - Configures server-level auditing policy
2. `azure-sql-jdbc-registration` - Registers JDBC connection with Guardium

## Azure SQL Database Audit Logging

Azure SQL Database server-level auditing captures:
- **Successful Authentication**: User login events
- **Failed Authentication**: Failed login attempts
- **Batch Completed**: SQL statement executions (SELECT, INSERT, UPDATE, DELETE, etc.)

## CSV Profile Upload

The module uploads the Universal Connector CSV profile to Guardium via API:
- CSV file is created in your local workspace (`.terraform/` directory)
- Provider uploads file content directly via HTTP multipart/form-data
- No additional configuration required
- Secure and easy to use
- Works seamlessly when using modules from remote sources (Git/Terraform Registry)

## JDBC Integration

This module configures JDBC integration for Azure SQL Database auditing. The audit logs are automatically sent to Azure Storage Account and queried using:

```
sys.fn_get_audit_file('https://<storage-account>.blob.core.windows.net/<container>/<server>/master/SqlDbAuditing_ServerAudit', DEFAULT, DEFAULT)
```

Guardium is configured to collect and analyze these logs through the Universal Connector using JDBC.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| azure_region | Azure region | string | `"eastus"` | no |
| resource_group_name | Name of the Azure resource group | string | n/a | yes |
| sql_server_name | Name of the SQL Server to be monitored | string | n/a | yes |
| sql_database_name | Name of the SQL Database to be monitored | string | n/a | yes |
| storage_account_name | Name of the storage account for audit logs | string | n/a | yes |
| audit_container_name | Name of the storage container for audit logs | string | `"sqldbauditlogs"` | no |
| retention_in_days | Number of days to retain audit logs | number | `90` | no |
| tags | Map of tags to apply to resources | map(string) | n/a | yes |
| credential_name | Name of JDBC credential in Guardium | string | `"azure-sql-jdbc-cred"` | no |
| jdbc_driver_library | Name of JDBC driver JAR file in Guardium | string | `"mssql-jdbc-7.4.1.jre8.jar"` | no |
| enrollment_id | Azure enrollment ID for multi-tenant support | string | `"123456789"` | no |
| gdp_client_secret | Client secret from Guardium | string | n/a | yes |
| gdp_client_id | Client ID from Guardium | string | n/a | yes |
| gdp_server | Guardium server hostname/IP | string | n/a | yes |
| gdp_port | Port of Guardium Central Manager | string | `"8443"` | no |
| gdp_username | Guardium username | string | n/a | yes |
| gdp_password | Guardium password | string | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units | string | n/a | yes |
| enable_universal_connector | Whether to enable the universal connector | bool | `true` | no |
| csv_start_position | Start position for UDC | string | `"end"` | no |
| csv_interval | Polling interval for UDC | string | `"60"` | no |
| codec_pattern | Codec pattern for the Universal Connector | string | `""` | no |
| csv_event_filter | UDC Event filters | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| profile_csv | Content of the profile CSV |
| udc_name | Name of the Universal Connector |
| sql_server_name | Name of the SQL Server |
| sql_database_name | Name of the SQL Database |
| sql_server_fqdn | Fully qualified domain name of SQL Server |
| storage_account_name | Name of the storage account |
| azure_region | Azure region where resources are deployed |
| subscription_id | Azure subscription ID |
| resource_group_name | Name of the resource group |
# Azure SQL Database with IBM Guardium Data Protection

This example demonstrates how to configure Azure SQL Database with IBM Guardium Data Protection using JDBC-based audit log collection for comprehensive monitoring.

## Architecture

```
┌───────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│                   │     │                   │     │                   │
│  Azure SQL        │────►│  Server-Level     │────►│  Azure Storage    │
│  Database         │     │  Auditing         │     │  Account          │
└───────────────────┘     └───────────────────┘     └───────────────────┘
                                                            │
                                                            │
                                                            ▼
                                                     ┌───────────────────┐
                                                     │                   │
                                                     │  Guardium         │
                                                     │  Universal        │
                                                     │  Connector        │
                                                     │                   │
                                                     └───────────────────┘
                                                            │
                                                            │
                                                            ▼
                                                     ┌───────────────────┐
                                                     │                   │
                                                     │  Guardium Data    │
                                                     │  Protection       │
                                                     │                   │
                                                     └───────────────────┘
```

## Data Flow

1. Azure SQL Database activity is captured by server-level auditing
2. Audit logs are written to Azure Storage Account
3. Guardium Universal Connector queries audit logs via JDBC using `sys.fn_get_audit_file()`
4. Guardium processes and analyzes the SQL Database activity
5. Security teams can view and alert on SQL Database activity in Guardium

## Overview

This Terraform configuration:

1. Configures an existing Azure SQL Database for audit logging via server-level auditing policy
2. Sets up a Universal Data Connector in Guardium to collect and analyze SQL Database audit logs using JDBC
3. Enables comprehensive monitoring of database operations, user activity, and access patterns

## Prerequisites

Before using this example, ensure you have:

1. **Azure Resources**:
   - An existing Azure SQL Server and Database

2. **Guardium Data Protection**:
   - A running Guardium Data Protection instance (version 12.2.1 or above)
   - Completed the one-time manual configurations as described in [Preparing Guardium Documentation](https://github.com/IBM/terraform-guardium-gdp/blob/main/docs/preparing-guardium.md):
      - OAuth client registered via `grdapi register_oauth_client`
      - JDBC credential configured in Guardium Data Protection
      - JDBC driver (mssql-jdbc-7.4.1.jre8.jar) uploaded to Guardium

## Usage

### 1. Create a terraform.tfvars File

Create a `terraform.tfvars` file with your configuration. See [terraform.tfvars.example](./terraform.tfvars.example) for an example with available options and detailed comments.

### 2. Initialize Terraform

  ```bash
  terraform init
  ```

### 3. Import Existing Audit Policies (if already configured)

If your Azure SQL Server already has audit policies configured, you need to import them into Terraform state before applying. **Both server-level and database-level audit policies must be imported separately.**

```bash
# Set your Azure resource details
SUBSCRIPTION_ID="<subscription-id>"
RESOURCE_GROUP="<resource-group>"
SERVER_NAME="<server-name>"
DATABASE_NAME="<database-name>"

# Import Server-Level Audit Policy
terraform import 'module.azure_sql_audit.module.common_azure-sql-audit-settings.azurerm_mssql_server_extended_auditing_policy.server_audit[0]' \
  "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Sql/servers/${SERVER_NAME}/extendedAuditingSettings/Default"

# Import Database-Level Audit Policy
terraform import 'module.azure_sql_audit.module.common_azure-sql-audit-settings.azurerm_mssql_database_extended_auditing_policy.database_audit[0]' \
  "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Sql/servers/${SERVER_NAME}/databases/${DATABASE_NAME}/extendedAuditingSettings/Default"
```

Replace the placeholders:
- `<subscription-id>`: Your Azure subscription ID (e.g., `5c0c81d4-656f-415d-8599-dcd86f2f665e`)
- `<resource-group>`: Your resource group name (e.g., `guardium-azuresql-1-rg`)
- `<server-name>`: Your SQL Server name (e.g., `guardium-azuresql-1-sqlserver-2dmd6362`)
- `<database-name>`: Your SQL Database name (e.g., `guardium-testdb`)

**Important Notes**:
- The audit setting name must be `Default` (capital D) in the resource ID
- Both imports are required if audit policies already exist
- If no audit policies exist, skip this step and proceed to apply

### 4. Apply the Configuration

  ```bash
  terraform apply
  ```

Review the planned changes and type `yes` to apply them.

### 5. Verify the Configuration

After successful application:

1. Log in to your Guardium Data Protection web interface
2. Navigate to **Universal Connector** → **Datasource Profile Management**
3. Verify that the Azure SQL Database profile has been created and is active
4. Navigate to the managed unit (collector) the UC is deployed on and ensure the STAP status is green/active

## JDBC Integration

The module configures Azure SQL Database to send audit logs to Storage Account. The Universal Connector then:

1. Connects to SQL Server using JDBC credentials
2. Queries audit logs from Storage Account using `sys.fn_get_audit_file()` function
3. Parses and normalizes the log data
4. Forwards the processed audit events to Guardium for analysis

## Azure SQL Database Audit Logging

Azure SQL Database server-level auditing captures:
- **Successful Authentication**: User login events
- **Failed Authentication**: Failed login attempts
- **Batch Completed**: SQL statement executions (SELECT, INSERT, UPDATE, DELETE, etc.)

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| azure_region | Azure region where resources are located | `string` | `"eastus"` | no |
| resource_group_name | Name of the Azure resource group | `string` | n/a | yes |
| sql_server_name | Name of the SQL Server to be monitored | `string` | n/a | yes |
| sql_database_name | Name of the SQL Database to be monitored | `string` | n/a | yes |
| storage_account_name | Name of the storage account for audit logs | `string` | n/a | yes |
| audit_container_name | Name of the storage container for audit logs | `string` | `"sqldbauditlogs"` | no |
| retention_in_days | Number of days to retain audit logs | `number` | `90` | no |
| credential_name | Name of JDBC credential in Guardium | `string` | `"azure-sql-jdbc-cred"` | no |
| jdbc_driver_library | Name of JDBC driver JAR file in Guardium | `string` | `"mssql-jdbc-7.4.1.jre8.jar"` | no |
| enrollment_id | Azure enrollment ID for multi-tenant support | `string` | `"123456789"` | no |
| gdp_client_id | Client ID used when running grdapi register_oauth_client | `string` | n/a | yes |
| gdp_client_secret | Client secret from output of grdapi register_oauth_client | `string` | n/a | yes |
| gdp_server | Hostname/IP address of Guardium Central Manager | `string` | n/a | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"` | no |
| gdp_username | Username of Guardium Web UI user | `string` | n/a | yes |
| gdp_password | Password of Guardium Web UI user | `string` | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units to deploy profile | `string` | `""` | no |
| enable_universal_connector | Whether to enable the universal connector | `bool` | `true` | no |
| csv_start_position | Start position for UDC | `string` | `"end"` | no |
| csv_interval | Polling interval for UDC | `string` | `"60"` | no |
| codec_pattern | Codec pattern for the Universal Connector | `string` | `""` | no |
| csv_event_filter | UDC Event filters | `string` | `""` | no |
| tags | Map of tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| udc_name | Name of the Universal Connector |
| sql_server_name | Name of the SQL Server |
| sql_database_name | Name of the SQL Database |
| sql_server_fqdn | Fully qualified domain name of SQL Server |
| storage_account_name | Name of the storage account |
| azure_region | Azure region where resources are deployed |
| resource_group_name | Resource group name |
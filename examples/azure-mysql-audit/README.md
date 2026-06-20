# Azure MySQL with IBM Guardium Data Protection

This example demonstrates how to configure Azure MySQL Flexible Server with IBM Guardium Data Protection using diagnostic settings and Event Hub for comprehensive monitoring.

**Supported Versions:** This module requires IBM Guardium Data Protection (GDP) version **12.2.1 and above**.

## Architecture

```
┌───────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│                   │     │                   │     │                   │
│  Azure MySQL      │────►│  Diagnostic       │────►│  Azure Event Hub  │
│  Flexible Server  │     │  Settings         │     │                   │
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

1. MySQL database activity is captured by diagnostic settings
2. Audit logs are streamed to Event Hub in real-time
3. Guardium Universal Connector reads from Event Hub
4. Guardium processes and analyzes the MySQL activity
5. Security teams can view and alert on MySQL activity in Guardium

## Overview

This Terraform configuration:

1. Configures an existing Azure MySQL Flexible Server for audit logging via diagnostic settings
2. Sets up a Universal Data Connector in Guardium to collect and analyze MySQL audit logs from Event Hub
3. Enables comprehensive monitoring of database operations, user activity, and access patterns

## Prerequisites

Before using this example, ensure you have:

1. **Azure Resources**:
   - An existing Azure MySQL Flexible Server
   - An existing Event Hub namespace and Event Hub
   - An existing Storage Account (for Event Hub checkpointing)
   - Resource group containing these resources

2. **MySQL Server Configuration**:
   - Audit logging enabled on the MySQL server (`audit_log_enabled = ON`)
   - Audit log events configured (e.g., `audit_log_events = CONNECTION,DML,DDL,DCL,ADMIN`)

3. **Guardium Data Protection**:
   - A running Guardium Data Protection instance (version 12.2.1 or above)
   - Completed the one-time manual configurations as described in [Preparing Guardium Documentation](https://github.com/IBM/terraform-guardium-gdp/blob/main/docs/preparing-guardium.md):
      - OAuth client registered via `grdapi register_oauth_client`
      - Azure credentials configured in Guardium Data Protection

## Usage

### 1. Authenticate with Azure CLI

Before running Terraform, ensure you are authenticated with Azure:

```bash
az login
```

If you have multiple subscriptions, set the default:

```bash
az account list --output table
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

Verify authentication:

```bash
az account show
```

### 2. Enable MySQL Audit Logging

Configure your MySQL Flexible Server to enable audit logging:

```bash
# Enable audit logging
az mysql flexible-server parameter set \
  --resource-group <resource-group> \
  --server-name <mysql-server-name> \
  --name audit_log_enabled \
  --value ON

# Configure audit events
az mysql flexible-server parameter set \
  --resource-group <resource-group> \
  --server-name <mysql-server-name> \
  --name audit_log_events \
  --value "CONNECTION,DML,DDL,DCL,ADMIN"
```

### 3. Create a terraform.tfvars File

Create a `terraform.tfvars` file with your configuration. See [terraform.tfvars.example](./terraform.tfvars.example) for an example with available options and detailed comments.

### 4. Initialize Terraform

  ```bash
  terraform init
  ```

### 5. Import the Diagnostic Setting (if already exists)

**Option A: Automated Import**

The module includes automated diagnostic setting detection. When you run `terraform plan`, the module will:
- Query your existing MySQL server to discover any existing diagnostic settings
- Automatically handle the import if a diagnostic setting exists
- Prevent "diagnostic setting already exists" errors
- Skip if no diagnostic setting exists (will create new one)

The automation uses external data sources with Azure CLI to fetch your MySQL diagnostic settings.

**Option B: Manual Import**

If you prefer to import manually or encounter issues with automated import:

Identify existing diagnostic setting name:

```bash
# Get current diagnostic setting name
az monitor diagnostic-settings list \
  --resource /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.DBforMySQL/flexibleServers/<mysql-server-name> \
  --query "[].name" \
  --output tsv
```

Import existing diagnostic setting:

```bash
terraform import 'module.datastore-audit_azure-mysql-audit.azurerm_monitor_diagnostic_setting.mysql_audit' \
  '/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.DBforMySQL/flexibleServers/<mysql-server-name>|<diagnostic-setting-name>'
```

**Note**: The automated approach is recommended. Manual import is only needed if you encounter specific issues or prefer explicit control. Skipping the import step will cause Terraform to attempt creating a new diagnostic setting, which may fail if one already exists.

### 6. Apply the Configuration

  ```bash
  terraform apply
  ```

Review the planned changes and type `yes` to apply them.

### 7. Verify the Configuration

After successful application:

1. Log in to your Guardium Data Protection web interface
2. Navigate to **Universal Connector** → **Datasource Profile Management**
3. Verify that the MySQL profile has been created and is active
4. Navigate to **Event Hubs** on the Azure Portal and verify that your Event Hub is receiving messages
5. Navigate to the managed unit (collector) the UC is deployed on and ensure the STAP status is green/active

## Event Hub Integration

The module configures MySQL to send audit logs to Event Hub. The Universal Connector then:

1. Reads these logs from Event Hub using the configured Azure credentials
2. Parses and normalizes the log data
3. Forwards the processed audit events to Guardium for analysis

## MySQL Audit Logging

MySQL diagnostic settings capture:
- **MySqlAuditLogs**: All audit events (connections, queries, DDL, DML, DCL, admin operations)
- **MySqlSlowLogs**: Slow query logs for performance analysis

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| azure_region | Azure region where resources are located (should match resource group location) | `string` | `"eastus"` | no |
| resource_group_name | Name of the Azure resource group | `string` | n/a | yes |
| mysql_server_name | Name of the MySQL Flexible Server to be monitored | `string` | n/a | yes |
| eventhub_namespace_name | Name of the Event Hub namespace | `string` | n/a | yes |
| eventhub_name | Name of the Event Hub | `string` | n/a | yes |
| eventhub_authorization_rule_name | Name of the Event Hub authorization rule | `string` | `"RootManageSharedAccessKey"` | no |
| storage_account_name | Name of the storage account for Event Hub checkpointing | `string` | n/a | yes |
| consumer_group | Event Hub consumer group name | `string` | `"$Default"` | no |
| diagnostic_setting_name | Name of the diagnostic setting | `string` | `"mysql-audit-to-eventhub"` | no |
| enable_mysql_audit_logs | Enable MySQL Audit logs | `bool` | `true` | no |
| audit_log_events | MySQL audit log events to capture (CONNECTION, GENERAL) | `string` | `"CONNECTION,GENERAL"` | no |
| gdp_client_id | Client ID used when running grdapi register_oauth_client | `string` | n/a | yes |
| gdp_client_secret | Client secret from output of grdapi register_oauth_client | `string` | n/a | yes |
| gdp_server | Hostname/IP address of Guardium Central Manager | `string` | n/a | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"` | no |
| gdp_username | Username of Guardium Web UI user | `string` | n/a | yes |
| gdp_password | Password of Guardium Web UI user | `string` | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units to deploy profile | `string` | `""` | no |
| enable_universal_connector | Whether to enable the universal connector | `bool` | `true` | no |
| initial_position | Initial position for Event Hub consumer (beginning/end) | `string` | `"end"` | no |
| config_mode | Configuration mode for Event Hub input (basic/advanced) | `string` | `"basic"` | no |
| threads | Number of threads for Event Hub consumer | `number` | `8` | no |
| decorate_events | Whether to decorate events with Event Hub metadata | `bool` | `true` | no |
| tags | Map of tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| udc_name | Name of the Universal Connector (format: `{mysql-server-name}-{subscription-id}`) |
| mysql_server_name | Name of the MySQL server |
| mysql_server_endpoint | Fully qualified domain name of the MySQL server |
| eventhub_namespace_name | Name of the Event Hub namespace |
| eventhub_name | Name of the Event Hub receiving logs |
| storage_account_name | Name of the storage account for checkpointing |
| azure_region | Azure region where resources are deployed |
| subscription_id | Azure subscription ID |
| resource_group_name | Resource group name |
| diagnostic_setting_name | Name of the diagnostic setting |

## Additional Resources

- [Azure MySQL Flexible Server Audit Logs](https://docs.microsoft.com/en-us/azure/mysql/flexible-server/concepts-audit-logs)
- [Azure MySQL Guardium Filter Plugin](https://github.com/IBM/universal-connectors/tree/main/filter-plugin/logstash-filter-mysql-azure-guardium)
- [IBM Guardium Data Protection Documentation](https://www.ibm.com/docs/en/guardium)
- [Guardium Universal Connector Guide](https://www.ibm.com/docs/en/guardium/12.2?topic=connectors-universal-connector)

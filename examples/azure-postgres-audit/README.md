# Azure PostgreSQL with IBM Guardium Data Protection

This example demonstrates how to configure Azure PostgreSQL Flexible Server with IBM Guardium Data Protection using diagnostic settings and Event Hub for comprehensive monitoring.

**Supported Versions:** This module requires IBM Guardium Data Protection (GDP) version **12.2.1 and above**.

## Architecture

```
┌───────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│                   │     │                   │     │                   │
│  Azure PostgreSQL │────►│  Diagnostic       │────►│  Azure Event Hub  │
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

1. PostgreSQL database activity is captured by diagnostic settings with pgAudit
2. Audit logs are streamed to Event Hub in real-time
3. Guardium Universal Connector reads from Event Hub
4. Guardium processes and analyzes the PostgreSQL activity
5. Security teams can view and alert on PostgreSQL activity in Guardium

## Overview

This Terraform configuration:

1. Configures an existing Azure PostgreSQL Flexible Server with pgAudit extension for comprehensive audit logging
2. Sets up diagnostic settings to stream audit logs to Event Hub
3. Sets up a Universal Data Connector in Guardium to collect and analyze PostgreSQL audit logs from Event Hub
4. Enables comprehensive monitoring of database operations, user activity, and access patterns

## Prerequisites

Before using this example, ensure you have:

1. **Azure Resources**:
   - An existing Azure PostgreSQL Flexible Server
   - An existing Event Hub namespace and Event Hub
   - An existing Storage Account (for Event Hub checkpointing)
   - Resource group containing these resources

2. **PostgreSQL Server Configuration**:
   - Server must support pgAudit extension (PostgreSQL 11+)
   - Sufficient permissions to modify server parameters

3. **Guardium Data Protection**:
   - A running Guardium Data Protection instance (version 12.2.2 or above)
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

### 2. Create a terraform.tfvars File

Create a `terraform.tfvars` file with your configuration. See [terraform.tfvars.example](./terraform.tfvars.example) for an example with available options and detailed comments.

### 3. Initialize Terraform

  ```bash
  terraform init
  ```

### 4. Import the Diagnostic Setting (if already exists)

**Option A: Automated Import**

The module includes automated diagnostic setting detection. When you run `terraform plan`, the module will:
- Query your existing PostgreSQL server to discover any existing diagnostic settings
- Automatically handle the import if a diagnostic setting exists
- Prevent "diagnostic setting already exists" errors
- Skip if no diagnostic setting exists (will create new one)

The automation uses external data sources with Azure CLI to fetch your PostgreSQL diagnostic settings.

**Option B: Manual Import**

If you prefer to import manually or encounter issues with automated import:

Identify existing diagnostic setting name:

```bash
# Get current diagnostic setting name
az monitor diagnostic-settings list \
  --resource /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.DBforPostgreSQL/flexibleServers/<postgres-server-name> \
  --query "[].name" \
  --output tsv
```

Import existing diagnostic setting:

```bash
terraform import 'module.datastore-audit_azure-postgres-audit.azurerm_monitor_diagnostic_setting.postgres_audit' \
  '/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.DBforPostgreSQL/flexibleServers/<postgres-server-name>|<diagnostic-setting-name>'
```

**Note**: The automated approach is recommended. Manual import is only needed if you encounter specific issues or prefer explicit control. Skipping the import step will cause Terraform to attempt creating a new diagnostic setting, which may fail if one already exists.

### 5. Apply the Configuration

  ```bash
  terraform apply
  ```

Review the planned changes and type `yes` to apply them.

### 6. Verify the Configuration

After successful application:

1. Log in to your Guardium Data Protection web interface
2. Navigate to **Universal Connector** → **Datasource Profile Management**
3. Verify that the PostgreSQL profile has been created and is active
4. Navigate to **Event Hubs** on the Azure Portal and verify that your Event Hub is receiving messages
5. Navigate to the managed unit (collector) the UC is deployed on and ensure the STAP status is green/active

## Event Hub Integration

The module configures PostgreSQL to send audit logs to Event Hub. The Universal Connector then:

1. Reads these logs from Event Hub using the configured Azure credentials
2. Parses and normalizes the log data
3. Forwards the processed audit events to Guardium for analysis

## PostgreSQL pgAudit Logging

The module automatically configures pgAudit extension with the following parameters based on the `Enabling Auditing` section in [Azure PostgreSQL Guardium Filter Plugin](https://github.com/IBM/universal-connectors/tree/main/filter-plugin/logstash-filter-azure-postgresql-guardium):

- **shared_preload_libraries**: PGAUDIT (loads the pgAudit extension)
- **pgaudit.log**: DDL,FUNCTION,READ,WRITE,ROLE (configurable - controls which statement classes are logged)
- **pgaudit.log_catalog**: off (controls logging of catalog queries)
- **pgaudit.log_client**: off (controls visibility of audit messages to client)
- **pgaudit.log_parameter**: off (controls inclusion of parameters in audit log)
- **log_line_prefix**: %t:%r:%u@%d:[%p]:%a:%e (includes timestamp, client IP:port, username, database, process ID, application name, SQL state)
- **log_error_verbosity**: VERBOSE (detailed error logging)

PostgreSQL diagnostic settings capture:
- **PostgreSQLLogs**: All audit events from pgAudit

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| azure_region | Azure region where resources are located (should match resource group location) | `string` | `"eastus"` | no |
| resource_group_name | Name of the Azure resource group | `string` | n/a | yes |
| postgres_server_name | Name of the PostgreSQL Flexible Server to be monitored | `string` | n/a | yes |
| eventhub_namespace_name | Name of the Event Hub namespace | `string` | n/a | yes |
| eventhub_name | Name of the Event Hub | `string` | n/a | yes |
| eventhub_authorization_rule_name | Name of the Event Hub authorization rule | `string` | `"RootManageSharedAccessKey"` | no |
| storage_account_name | Name of the storage account for Event Hub checkpointing | `string` | n/a | yes |
| consumer_group | Event Hub consumer group name | `string` | `"$Default"` | no |
| pgaudit_log | Statement classes to log (READ, WRITE, FUNCTION, ROLE, DDL, MISC, ALL) | `string` | `"DDL,FUNCTION,READ,WRITE,ROLE"` | no |
| pgaudit_log_catalog | Log catalog queries | `bool` | `false` | no |
| pgaudit_log_client | Show audit messages to client | `bool` | `false` | no |
| pgaudit_log_parameter | Include parameters in log | `bool` | `false` | no |
| log_checkpoints | Log checkpoints | `bool` | `false` | no |
| log_error_verbosity | Error verbosity level (TERSE, DEFAULT, VERBOSE) | `string` | `"VERBOSE"` | no |
| log_line_prefix | Log line prefix format | `string` | `"%t:%r:%u@%d:[%p]:%a:%e"` | no |
| gdp_client_id | Client ID used when running grdapi register_oauth_client | `string` | n/a | yes |
| gdp_client_secret | Client secret from output of grdapi register_oauth_client | `string` | n/a | yes |
| gdp_server | Hostname/IP address of Guardium Central Manager | `string` | n/a | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"` | no |
| gdp_username | Username of Guardium Web UI user | `string` | n/a | yes |
| gdp_password | Password of Guardium Web UI user | `string` | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units to deploy profile | `string` | `""` | no |
| azure_enrollment_id | Azure Enrollment ID (required) | `string` | n/a | yes |
| enable_universal_connector | Whether to enable the universal connector | `bool` | `true` | no |
| initial_position | Initial position for Event Hub consumer (beginning/end) | `string` | `"end"` | no |
| config_mode | Configuration mode for Event Hub input (basic/advanced) | `string` | `"basic"` | no |
| threads | Number of threads for Event Hub consumer | `number` | `8` | no |
| decorate_events | Whether to decorate events with Event Hub metadata | `bool` | `true` | no |
| tags | Map of tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| udc_name | Name of the Universal Connector (format: `{postgres-server-name}-{subscription-id}`) |
| postgres_server_name | Name of the PostgreSQL server |
| postgres_server_endpoint | Fully qualified domain name of the PostgreSQL server |
| eventhub_namespace_name | Name of the Event Hub namespace |
| eventhub_name | Name of the Event Hub receiving logs |
| storage_account_name | Name of the storage account for checkpointing |
| azure_region | Azure region where resources are deployed |
| subscription_id | Azure subscription ID |
| resource_group_name | Resource group name |
| diagnostic_setting_name | Name of the diagnostic setting |
| pgaudit_configuration | Summary of pgAudit configuration |

## Additional Resources

- [Azure PostgreSQL Flexible Server Documentation](https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/)
- [pgAudit Documentation](https://github.com/pgaudit/pgaudit)
- [IBM Guardium Data Protection Documentation](https://www.ibm.com/docs/en/guardium)
- [Guardium Universal Connector Guide](https://www.ibm.com/docs/en/guardium/12.2?topic=connectors-universal-connector)

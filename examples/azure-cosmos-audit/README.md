# Azure Cosmos DB with IBM Guardium Data Protection

This example demonstrates how to configure Azure Cosmos DB with IBM Guardium Data Protection using diagnostic settings and Event Hub for comprehensive monitoring.

## Architecture

```
┌───────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│                   │     │                   │     │                   │
│  Azure Cosmos DB  │────►│  Diagnostic       │────►│  Azure Event Hub  │
│  Account          │     │  Settings         │     │                   │
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

1. Cosmos DB database activity is captured by diagnostic settings
2. Audit logs are streamed to Event Hub in real-time
3. Guardium Universal Connector reads from Event Hub
4. Guardium processes and analyzes the Cosmos DB activity
5. Security teams can view and alert on Cosmos DB activity in Guardium

## Overview

This Terraform configuration:

1. Configures an existing Azure Cosmos DB account for audit logging via diagnostic settings
2. Sets up a Universal Data Connector in Guardium to collect and analyze Cosmos DB audit logs from Event Hub
3. Enables comprehensive monitoring of database operations, user activity, and access patterns

## Prerequisites

Before using this example, ensure you have:

1. **Azure Resources**:
   - An existing Azure Cosmos DB account
   - An existing Event Hub namespace and Event Hub
   - An existing Storage Account (for Event Hub checkpointing)
   - Resource group containing these resources

2. **Guardium Data Protection**:
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

### 2. Create a terraform.tfvars File

Create a `terraform.tfvars` file with your configuration. See [terraform.tfvars.example](./terraform.tfvars.example) for an example with available options and detailed comments.

### 2. Initialize Terraform

  ```bash
  terraform init
  ```

### 3. Import the Diagnostic Setting (if already exists)

**Option A: Automated Import (Recommended)**

The module includes automated diagnostic setting detection. When you run `terraform plan`, the module will:
- Query your existing Cosmos DB account to discover any existing diagnostic settings
- Automatically handle the import if a diagnostic setting exists
- Prevent "diagnostic setting already exists" errors
- Skip if no diagnostic setting exists (will create new one)

The automation uses external data sources with Azure CLI to fetch your Cosmos DB diagnostic settings.

**Option B: Manual Import**

If you prefer to import manually or encounter issues with automated import:

Identify existing diagnostic setting name:

```bash
# Get current diagnostic setting name
az monitor diagnostic-settings list \
  --resource /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.DocumentDB/databaseAccounts/<cosmos-account-name> \
  --query "[].name" \
  --output tsv
```

Import existing diagnostic setting:

```bash
terraform import 'module.datastore-audit_azure-cosmos-audit.module.common_azure-cosmos-diagnostic-settings.azurerm_monitor_diagnostic_setting.cosmos_audit' \
  '/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.DocumentDB/databaseAccounts/<cosmos-account-name>|<diagnostic-setting-name>'
```

**Note**: The automated approach is recommended. Manual import is only needed if you encounter specific issues or prefer explicit control. Skipping the import step will cause Terraform to attempt creating a new diagnostic setting, which may fail if one already exists.

### 4. Apply the Configuration

  ```bash
  terraform apply
  ```

Review the planned changes and type `yes` to apply them.

### 5. Verify the Configuration

After successful application:

1. Log in to your Guardium Data Protection web interface
2. Navigate to **Universal Connector** → **Datasource Profile Management**
3. Verify that the Cosmos DB profile has been created and is active
4. Navigate to **Event Hubs** on the Azure Portal and verify that your Event Hub is receiving messages
5. Navigate to the managed unit (collector) the UC is deployed on and ensure the STAP status is green/active

## Event Hub Integration

The module configures Cosmos DB to send audit logs to Event Hub. The Universal Connector then:

1. Reads these logs from Event Hub using the configured Azure credentials
2. Parses and normalizes the log data
3. Forwards the processed audit events to Guardium for analysis

## Cosmos DB Audit Logging

Cosmos DB diagnostic settings capture:
- **DataPlaneRequests**: All data operations (queries, CRUD operations)
- **QueryRuntimeStatistics**: Query performance metrics and execution details
- **ControlPlaneRequests**: Management operations (account configuration changes)

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| azure_region | Azure region where resources are located | `string` | `"eastus"` | no |
| resource_group_name | Name of the Azure resource group | `string` | n/a | yes |
| cosmos_account_name | Name of the Cosmos DB account to be monitored | `string` | n/a | yes |
| event_hub_namespace | Name of the Event Hub namespace | `string` | n/a | yes |
| event_hub_name | Name of the Event Hub | `string` | n/a | yes |
| event_hub_authorization_rule_id | Resource ID of the Event Hub authorization rule | `string` | n/a | yes |
| storage_account_name | Name of the storage account for Event Hub checkpointing | `string` | n/a | yes |
| storage_container_name | Name of the storage container for Event Hub checkpointing | `string` | `"eventhub-checkpoint"` | no |
| enable_data_plane_logs | Enable DataPlaneRequests logs | `bool` | `true` | no |
| enable_query_runtime_logs | Enable QueryRuntimeStatistics logs | `bool` | `true` | no |
| enable_control_plane_logs | Enable ControlPlaneRequests logs | `bool` | `true` | no |
| gdp_client_id | Client ID used when running grdapi register_oauth_client | `string` | n/a | yes |
| gdp_client_secret | Client secret from output of grdapi register_oauth_client | `string` | n/a | yes |
| gdp_server | Hostname/IP address of Guardium Central Manager | `string` | n/a | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"` | no |
| gdp_username | Username of Guardium Web UI user | `string` | n/a | yes |
| gdp_password | Password of Guardium Web UI user | `string` | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units to deploy profile | `string` | `""` | no |
| enable_universal_connector | Whether to enable the universal connector | `bool` | `true` | no |
| csv_start_position | Start position for UDC (beginning/end) | `string` | `"end"` | no |
| csv_interval | Polling interval for UDC in seconds | `string` | `"5"` | no |
| consumer_group | Event Hub consumer group name | `string` | `"$Default"` | no |
| tags | Map of tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| udc_name | Name of the Universal Connector |
| diagnostic_setting_name | Name of the diagnostic setting |
| diagnostic_setting_id | Resource ID of the diagnostic setting |
| event_hub_name | Name of the Event Hub receiving logs |
| cosmos_account_endpoint | Cosmos DB account endpoint |
| azure_region | Azure region where resources are deployed |
| resource_group_name | Resource group name |

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

1. Cosmos DB database activity is captured by Azure diagnostic settings
2. Audit logs are streamed to Azure Event Hub in real-time
3. Guardium Universal Connector reads from Event Hub
4. Guardium processes and analyzes the Cosmos DB activity
5. Security teams can view and alert on Cosmos DB activity in Guardium

## Overview

This Terraform configuration:

1. Configures diagnostic settings for an existing Azure Cosmos DB account
2. Streams audit logs to Azure Event Hub
3. Sets up a Universal Data Connector in Guardium to collect and analyze Cosmos DB audit logs from Event Hub
4. Enables comprehensive monitoring of database operations, user activity, and access patterns

## Prerequisites

Before using this example, ensure you have:

1. **Azure Resources**:
   - An existing Azure Cosmos DB account
   - An existing Event Hub namespace and Event Hub
   - An existing Storage Account for Event Hub checkpointing
   - All resources in the same Azure subscription and resource group

2. **Guardium Data Protection**:
   - A running Guardium Data Protection instance (version 12.2.1 or above)
   - Completed the one-time manual configurations as described in [Preparing Guardium Documentation](https://github.com/IBM/terraform-guardium-gdp/blob/main/docs/preparing-guardium.md):
      - OAuth client registered via `grdapi register_oauth_client`
      - Azure credentials configured in Guardium Data Protection

## Usage

### 1. Create Infrastructure

First, create the required Azure infrastructure using the setup-middleware module from the guardium-terraform repository:

```bash
# Navigate to the guardium-terraform repository
cd /path/to/guardium-terraform/setup-middleware/azure-cosmos

# Copy and edit the terraform.tfvars file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration

# Initialize and apply
terraform init
terraform apply
```

This will create:
- Azure Cosmos DB account
- Event Hub namespace and Event Hub
- Storage Account for checkpointing
- Diagnostic settings configured

### 2. Configure Audit Settings

After the infrastructure is created, use this example to configure audit logging and Guardium integration:

```bash
# Navigate to this example directory
cd /path/to/terraform-guardium-datastore-audit/examples/azure-cosmos-audit

# Create a terraform.tfvars file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Import the Diagnostic Setting

**Option A: Automated Import (Recommended)**

The module includes automated diagnostic setting detection. When you run `terraform plan`, the module will:
- Query your existing Cosmos DB account to discover the current diagnostic settings
- Automatically handle the import if they exist
- Prevent "diagnostic setting already exists" errors

The automation uses Terraform data sources to fetch your Cosmos DB configuration and extract the diagnostic setting names.

**Option B: Manual Import**

If you prefer to import manually or encounter issues with automated import:

First, identify the existing diagnostic setting name:

```bash
# Get current diagnostic setting name
az monitor diagnostic-settings list \
  --resource /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.DocumentDB/databaseAccounts/<cosmos-account> \
  --query "[].name" -o tsv
```

If you see a diagnostic setting name (e.g., `glenn-nexus-cosmos-diagnostics`), import it:

```bash
terraform import \
  'module.datastore-audit_azure-cosmos-audit.azurerm_monitor_diagnostic_setting.cosmos_audit' \
  '/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.DocumentDB/databaseAccounts/<cosmos-account>|<diagnostic-setting-name>'
```

**Example**:
```bash
terraform import \
  'module.datastore-audit_azure-cosmos-audit.azurerm_monitor_diagnostic_setting.cosmos_audit' \
  '/subscriptions/0d7348f2-27a0-4fd2-8a5e-d9b7df304533/resourceGroups/SystemTestResourceGroup/providers/Microsoft.DocumentDB/databaseAccounts/glenn-nexus-cosmos-guardium|glenn-nexus-cosmos-diagnostics'
```

**Note**: Replace the values with your actual:
- `<subscription-id>`: Your Azure subscription ID
- `<resource-group>`: Your resource group name
- `<cosmos-account>`: Your Cosmos DB account name
- `<diagnostic-setting-name>`: The name of the existing diagnostic setting

After importing, run `terraform plan` to verify that Terraform recognizes the existing resource and won't try to recreate it.

### 5. Review the Plan

```bash
terraform plan
```

### 6. Apply the Configuration

```bash
terraform apply
```

## Configuration

### Required Variables

The following variables must be set in your `terraform.tfvars` file:

```hcl
# Azure Configuration
azure_region            = "eastus"
resource_group_name     = "my-resource-group"
cosmos_account_name     = "my-cosmos-account"

# Event Hub Configuration
eventhub_namespace_name = "my-eventhub-namespace"
eventhub_name           = "cosmos-audit-logs"
storage_account_name    = "mystorageaccount"

# Guardium Configuration
gdp_server             = "guardium.example.com"
gdp_username           = "admin"
gdp_password           = "your-password"
gdp_client_id          = "client1"
gdp_client_secret      = "your-client-secret"
gdp_mu_host            = "guardium-mu.example.com"
udc_azure_credential   = "azure-credential-name"
```

### Optional Variables

You can customize the audit logging behavior:

```hcl
# Enable/disable specific log categories
enable_data_plane_logs     = true   # CRUD operations
enable_query_runtime_logs  = true   # Query performance
enable_control_plane_logs  = true   # Management operations
enable_partition_key_logs  = false  # Partition statistics
enable_partition_ru_logs   = false  # RU consumption

# Universal Connector settings
csv_start_position = "end"
csv_interval       = "5"
```

## Verification

After applying the configuration, verify the setup:

### 1. Check Diagnostic Settings

```bash
az monitor diagnostic-settings show \
  --resource /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.DocumentDB/databaseAccounts/<cosmos-account> \
  --name cosmos-audit-to-eventhub
```

### 2. Check Event Hub Messages

```bash
# View Event Hub metrics in Azure Portal
# Navigate to: Event Hub Namespace > Event Hub > Metrics
# Check "Incoming Messages" metric
```

### 3. Verify Guardium Universal Connector

1. Log in to Guardium Web UI
2. Navigate to: Setup > Tools and Views > Configure Universal Connector
3. Verify the connector is listed and active
4. Check the connector logs for any errors

### 4. Test Data Operations

Perform some operations on your Cosmos DB account:

```bash
# Using Azure Portal Data Explorer or Azure CLI
az cosmosdb sql container create \
  --account-name <cosmos-account> \
  --database-name <database-name> \
  --name test-container \
  --partition-key-path "/id"
```

Then verify the audit logs appear in Guardium.

## Log Categories

This example enables the following log categories by default:

- **DataPlaneRequests**: CRUD operations on documents
- **QueryRuntimeStatistics**: Query performance metrics
- **ControlPlaneRequests**: Management operations

Optional categories (disabled by default):
- **PartitionKeyStatistics**: Partition-level statistics
- **PartitionKeyRUConsumption**: RU consumption per partition

### Profile Not Appearing in CM or MU

The Terraform Guardium provider resources (`import_profiles` and `install_connector`) only execute when Terraform detects changes. If you run `terraform apply` multiple times with the same configuration, these resources may be skipped even though the profile isn't in CM/MU.

**Solution: Clean State for Fresh Deployment**

When the profile doesn't appear in CM or isn't installed on MU, remove the Terraform state to force a fresh deployment:

```bash
# Remove Terraform state and generated files
rm -rf terraform.tfstate* .terraform/*.csv

# Re-apply to create everything fresh
terraform apply -var="udc_azure_credential=" -auto-approve
```

**Why This Happens:**
- The provider resources don't have built-in change detection for external state (CM/MU)
- Terraform sees no changes to the CSV file content, so skips execution
- Removing state forces Terraform to recreate all resources, triggering the actual API calls

**Note:** This approach is safe because:
- Azure resources (Cosmos DB, Event Hub, Storage) are managed separately by the infrastructure module
- Only the diagnostic settings and Guardium profile/connector resources are recreated
- No data loss occurs as Azure resources remain intact

**Verification Steps:**

1. **Check profile in CM**:
   - Navigate to Guardium UI → Datasource Profile Management
   - Look for profile with name matching your `udc_name` output
   - Profile definition should be: `Azure Cosmos over Event Hub`

2. **Check connector on MU**:
   - SSH to your MU host
   - Check connector status: `sudo systemctl status guardium-connector-*`
   - Verify logs: `sudo journalctl -u guardium-connector-* -f`

3. **Verify CSV file was generated**:
   ```bash
   ls -la .terraform/*.csv
   cat .terraform/*.csv
   ```

## Troubleshooting

### No Logs Appearing in Event Hub

1. Verify diagnostic settings are configured:
   ```bash
   az monitor diagnostic-settings list \
     --resource /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.DocumentDB/databaseAccounts/<cosmos-account>
   ```

2. Check Event Hub authorization rule has appropriate permissions

3. Verify Cosmos DB is generating activity (perform some operations)

### Universal Connector Not Processing Logs

1. Verify Azure credentials in Guardium are correct
2. Check network connectivity between Guardium and Azure
3. Review Universal Connector logs in Guardium UI
4. Verify Event Hub consumer group is accessible

### Authentication Errors

1. Verify Guardium OAuth client credentials
2. Check Guardium user has appropriate permissions
3. Ensure OAuth client is properly registered via `grdapi register_oauth_client`

## Cleanup

To remove all resources created by this example:

```bash
terraform destroy
```

**Note**: This will only remove the diagnostic settings. The Cosmos DB account, Event Hub, and Storage Account created by the setup-middleware module must be destroyed separately.

## Additional Resources

- [Azure Cosmos DB Diagnostic Logs](https://docs.microsoft.com/en-us/azure/cosmos-db/monitor-cosmos-db)
- [Azure Event Hubs Documentation](https://docs.microsoft.com/en-us/azure/event-hubs/)
- [IBM Guardium Data Protection Documentation](https://www.ibm.com/docs/en/guardium)
- [Guardium Universal Connector Guide](https://www.ibm.com/docs/en/guardium/12.2?topic=connectors-universal-connector)

## License

```text
#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#
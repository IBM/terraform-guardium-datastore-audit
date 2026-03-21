# Azure Cosmos DB with IBM Guardium Data Protection

This example configures Azure Cosmos DB audit logging with IBM Guardium Data Protection using diagnostic settings and Event Hub.

## Architecture

```
Azure Cosmos DB → Diagnostic Settings → Event Hub → Guardium UC → Guardium Data Protection
```

## Prerequisites

1. **Existing Azure Resources**:
   - Azure Cosmos DB account
   - Event Hub namespace and Event Hub
   - Storage account (for Event Hub checkpointing)
   - Resource group

2. **Guardium Configuration**:
   - Guardium Data Protection 12.2.1+
   - OAuth client registered (`grdapi register_oauth_client`)
   - Azure credentials configured in Guardium

3. **Tools**:
   - Terraform 1.0+
   - Azure CLI configured

## Quick Start

### 1. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration
```

### 2. Initialize and Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Configuration Options

### Diagnostic Log Types

```hcl
# Enable specific log categories
enable_data_plane_logs    = true  # Data operations (queries, CRUD)
enable_query_runtime_logs = true  # Query performance metrics
enable_control_plane_logs = true  # Management operations
```

### Universal Connector Settings

```hcl
# Start from end of logs (recommended for existing accounts)
csv_start_position = "end"

# Start from beginning (for new accounts or full history)
csv_start_position = "beginning"

# Polling interval in seconds
csv_interval = "5"
```

## Event Hub Configuration

The module streams logs to Event Hub with the following pattern:
```
<event-hub-namespace>.servicebus.windows.net/<event-hub-name>
```

## Outputs

After deployment:

```bash
terraform output
```

Outputs include:
- `udc_name` - Universal connector name
- `event_hub_name` - Event Hub receiving logs
- `diagnostic_setting_name` - Diagnostic setting name
- `cosmos_account_endpoint` - Cosmos DB endpoint

## Troubleshooting

### Issue: Connector not receiving logs

**Solution**: Verify:
1. Diagnostic settings are enabled on Cosmos DB
2. Event Hub connection string is correct
3. Azure credentials in Guardium have Event Hub read permissions
4. Consumer group exists in Event Hub

### Issue: Authentication errors

**Solution**: Verify:
1. Azure credential name matches what's configured in Guardium
2. OAuth client credentials are correct
3. Guardium user has appropriate permissions

### Issue: No audit logs generated

**Solution**: Verify diagnostic settings:
```bash
az monitor diagnostic-settings show \
  --name <diagnostic-setting-name> \
  --resource <cosmos-account-resource-id>
```

Check that enabled log categories match your configuration.
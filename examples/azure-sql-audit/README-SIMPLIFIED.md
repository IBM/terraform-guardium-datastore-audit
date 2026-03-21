# Azure SQL Database with IBM Guardium Data Protection

This example configures Azure SQL Database audit logging with IBM Guardium Data Protection using extended auditing policies and JDBC pull model.

## Architecture

```
Azure SQL Database → Extended Auditing → Storage Account → Guardium UC (JDBC) → Guardium Data Protection
```

## Prerequisites

1. **Existing Azure Resources**:
   - Azure SQL Server
   - Azure SQL Database
   - Storage account (for audit logs)
   - Resource group

2. **Guardium Configuration**:
   - Guardium Data Protection 12.2.1+
   - OAuth client registered (`grdapi register_oauth_client`)
   - Network connectivity to Azure SQL (port 1433)

3. **Tools**:
   - Terraform 1.0+
   - Azure CLI configured

## Quick Start

### 1. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration
```

### 2. Import Existing Audit Policies (if any)

If you have existing audit policies, uncomment and update the import blocks in `imports.tf`:

```hcl
import {
  to = module.datastore-audit_azure-sql-audit.module.common_azure-sql-audit-settings.azurerm_mssql_server_extended_auditing_policy.server_audit[0]
  id = "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Sql/servers/{server-name}/extendedAuditingSettings/default"
}
```

### 3. Initialize and Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Configuration Options

### Audit Policy Settings

```hcl
# Enable server-level auditing
enable_server_audit = true

# Enable database-level auditing
enable_database_audit = true

# Retention period in days (0 = unlimited)
retention_in_days = 90
```

### Universal Connector Settings

```hcl
# Enable automatic connector deployment (requires working provider)
enable_universal_connector = true

# Or disable for manual CSV upload
enable_universal_connector = false

# JDBC query interval in cron format (every minute)
csv_schedule = "*/1 * * * *"
```

## JDBC Pull Model

The Universal Connector uses JDBC to query audit logs from Azure Storage:

```sql
SELECT * FROM sys.fn_get_audit_file(
  'https://{storage-account}.blob.core.windows.net/{container}/*',
  default,
  default
)
WHERE event_time > DATEADD(minute, -5, GETUTCDATE())
ORDER BY event_time DESC
```

## Outputs

After deployment:

```bash
terraform output
```

Outputs include:
- `server_name` - Azure SQL Server name
- `database_name` - Azure SQL Database name
- `storage_account_name` - Storage account for audit logs
- `profile_csv` - CSV profile for manual upload (if connector disabled)

## Manual Connector Setup

If `enable_universal_connector = false`, follow these steps:

1. Get the CSV profile:
   ```bash
   terraform output -raw profile_csv > profile.csv
   ```

2. Upload to Guardium:
   - Navigate to: Setup → Tools and Views → Configure Universal Connector
   - Click "Upload File" and select `profile.csv`
   - Click "Install Connector"

3. Verify installation:
   - Check connector status in Guardium UI
   - Monitor audit logs in Reports

## Troubleshooting

### Issue: Connector not receiving logs

**Solution**: Verify:
1. Extended auditing policies are enabled on SQL Server and Database
2. JDBC connection string is correct
3. SQL credentials have permission to query `sys.fn_get_audit_file()`
4. Storage account contains audit log files

### Issue: Authentication errors

**Solution**: Verify:
1. SQL username and password are correct
2. Firewall rules allow Guardium IP addresses
3. OAuth client credentials are correct in Guardium
4. Guardium user has appropriate permissions

### Issue: No audit logs generated

**Solution**: Verify audit policies:
```bash
az sql server audit-policy show \
  --resource-group <resource-group> \
  --server <server-name>

az sql db audit-policy show \
  --resource-group <resource-group> \
  --server <server-name> \
  --name <database-name>
```

Check that:
- `state` is "Enabled"
- `storageAccountSubscriptionId` is set
- `storageEndpoint` points to your storage account

### Issue: sys.fn_get_audit_file() returns no rows

**Solution**: 
1. Generate database activity to create audit logs
2. Wait 1-2 minutes for logs to be written to storage
3. Verify storage account contains `.xel` files in the `sqldbauditlogs` container
4. Check the time filter in the query matches recent activity
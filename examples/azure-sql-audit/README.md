# Azure SQL Audit Example

This example demonstrates how to use the `azure-sql-audit` module to configure Azure SQL Database auditing and integrate with IBM Guardium Data Protection.

## Prerequisites

1. **Azure Resources** (already deployed):
   - Azure SQL Server
   - Azure SQL Database
   - Azure Storage Account for audit logs
   - Resource Group

2. **Guardium Setup**:
   - Guardium Central Manager with OAuth client registered
   - One or more Guardium Managed Units
   - Network connectivity from Guardium to Azure SQL Server

3. **Credentials**:
   - Azure subscription with appropriate permissions
   - SQL Server admin credentials
   - Guardium admin credentials

## Usage

1. **Copy the example terraform.tfvars file**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars** with your values:
   ```hcl
   # Azure Configuration
   azure_region         = "eastus"
   resource_group_name  = "my-resource-group"
   sql_server_name      = "my-sql-server"
   sql_database_name    = "my-database"
   storage_account_name = "mysqlauditstorage"
   
   # JDBC Configuration
   jdbc_user     = "sqladmin"
   jdbc_password = "YourSecurePassword123!"
   enrollment_id = "12345678"
   
   # Guardium Configuration
   gdp_client_id     = "your-client-id"
   gdp_client_secret = "your-client-secret"
   gdp_server        = "guardium-cm.example.com"
   gdp_username      = "admin"
   gdp_password      = "your-guardium-password"
   gdp_mu_host       = "guardium-mu1.example.com,guardium-mu2.example.com"
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Review the plan**:
   ```bash
   terraform plan
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

## What This Example Does

1. **Configures Audit Policies**:
   - Server-level auditing policy
   - Database-level auditing policy
   - Sends audit logs to Azure Storage Account

2. **Registers Universal Connector**:
   - Creates JDBC connection to SQL Server
   - Configures SQL query to retrieve audit logs using `sys.fn_get_audit_file()`
   - Sets up incremental tracking using `updatedeventtime` column

3. **Deploys UC Profile**:
   - Automatically deploys profile to Guardium CM
   - Distributes profile to specified Managed Units

## Architecture

```
Azure SQL Server
    ↓ (audit logs)
Azure Storage Account
    ↓ (JDBC query via sys.fn_get_audit_file)
Guardium Universal Connector
    ↓ (parsed events)
Guardium Managed Units
```

## Key Features

- **JDBC Pull Model**: UC queries audit logs directly from Storage Account
- **Incremental Tracking**: Only processes new audit records
- **Multi-Tenant Support**: Uses enrollment ID for tenant isolation
- **Automatic Deployment**: Profile deployed to CM and MUs automatically

## Outputs

After successful deployment, you'll see:

- `profile_csv`: The generated UC profile CSV content
- `udc_name`: Name of the Universal Connector
- `sql_server_fqdn`: Fully qualified domain name of SQL Server
- `jdbc_connection_string`: JDBC connection string (without credentials)
- `server_audit_policy_id`: ID of server-level audit policy
- `database_audit_policy_id`: ID of database-level audit policy

## Troubleshooting

### Issue: Cannot connect to SQL Server
- Verify firewall rules allow Guardium IP addresses
- Check SQL Server admin credentials
- Ensure SSL/TLS is properly configured

### Issue: No audit logs appearing
- Verify audit policies are enabled
- Check Storage Account permissions
- Ensure audit logs are being generated (run test queries)

### Issue: Profile deployment fails
- Verify Guardium OAuth client is registered
- Check Guardium admin credentials
- Ensure network connectivity to Guardium CM

## Clean Up

To remove all resources:

```bash
terraform destroy
```

**Note**: This only removes the audit configuration and UC profile. The Azure SQL Server, Database, and Storage Account are not destroyed.

## Related Documentation

- [Azure SQL Audit Module](../../modules/azure-sql-audit/README.md)
- [Azure SQL Database Auditing](https://learn.microsoft.com/en-us/azure/azure-sql/database/auditing-overview)
- [sys.fn_get_audit_file](https://learn.microsoft.com/en-us/sql/relational-databases/system-functions/sys-fn-get-audit-file-transact-sql)
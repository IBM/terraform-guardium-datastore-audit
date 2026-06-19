# Azure PostgreSQL Audit Configuration

This module configures audit logging for Azure PostgreSQL Flexible Server with IBM Guardium Data Protection using pgAudit extension. It enables diagnostic settings to stream audit logs to Azure Event Hub and configures Guardium Universal Connector for log collection.

**Supported Versions:** This module requires IBM Guardium Data Protection (GDP) version **12.2.1 and above**.

## Prerequisites

Before using this module, you need to:

1. Have an existing Azure PostgreSQL Flexible Server
2. Have Event Hub namespace and Event Hub created for audit log streaming
3. Have Storage Account created for Event Hub checkpointing
4. Have Guardium set up with appropriate credentials
5. Have Azure credentials configured in Guardium Universal Connector

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | ~> 3.0 |
| guardium-data-protection | >= 1.2.0 |

## Features

- Configures Azure PostgreSQL Flexible Server with pgAudit extension
- Enables comprehensive audit logging with configurable parameters
- Streams audit logs to Azure Event Hub
- Captures PostgreSQL audit logs:
  - PostgreSQLLogs (audit events from pgAudit)
- Integrates with Guardium for audit data collection via Event Hub
- Automatic Universal Connector profile deployment

## pgAudit Configuration

This module automatically configures the following PostgreSQL parameters:

### Required pgAudit Parameters

1. **shared_preload_libraries** = `PGAUDIT`
   - Loads the pgAudit extension

2. **pgaudit.log** = `DDL,FUNCTION,READ,WRITE,ROLE` (default)
   - Controls which statement classes are logged
   - Options: READ, WRITE, FUNCTION, ROLE, DDL, MISC, ALL

3. **pgaudit.log_catalog** = `off` (default)
   - Controls logging of catalog queries

4. **pgaudit.log_client** = `off` (default)
   - Controls visibility of audit messages to client

5. **pgaudit.log_parameter** = `off` (default)
   - Controls inclusion of parameters in audit log

### Additional Logging Parameters

6. **log_checkpoints** = `off` (default)
   - Logs checkpoint and restartpoint events

7. **log_error_verbosity** = `VERBOSE` (default)
   - Controls detail level in server log (TERSE, DEFAULT, VERBOSE)

8. **log_line_prefix** = `%t:%r:%u@%d:[%p]:%a:%e` (default)
   - Prefixes each log line with:
     - %t: timestamp
     - %r: client IP:port
     - %u: username
     - %d: database name
     - %p: process ID
     - %a: application name
     - %e: SQL state

## Diagnostic Setting Import Process

To ensure Terraform manages your PostgreSQL diagnostic settings correctly:

1. Initialize Terraform in your working directory:
   ```bash
   terraform init
   ```

2. Check if diagnostic setting exists:
   ```bash
   az monitor diagnostic-settings list \
     --resource /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.DBforPostgreSQL/flexibleServers/<postgres-server-name> \
     --query "[].name" \
     --output tsv
   ```

3. If a diagnostic setting exists with the same name, import it:
   ```bash
   terraform import azurerm_monitor_diagnostic_setting.postgres_audit \
     "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.DBforPostgreSQL/flexibleServers/<postgres-server-name>|<diagnostic-setting-name>"
   ```

## Usage

```hcl
module "azure_postgres_audit" {
  source = "../../modules/azure-postgres-audit"

  # Azure Configuration
  azure_region         = "eastus"
  resource_group_name  = "my-resource-group"
  postgres_server_name = "my-postgres-server"

  # Event Hub Configuration
  eventhub_namespace_name          = "my-eventhub-namespace"
  eventhub_name                    = "postgres-audit-logs"
  eventhub_authorization_rule_name = "RootManageSharedAccessKey"
  storage_account_name             = "mystorageaccount"

  # pgAudit Configuration
  pgaudit_log           = "DDL,FUNCTION,READ,WRITE,ROLE"
  pgaudit_log_catalog   = false
  pgaudit_log_client    = false
  pgaudit_log_parameter = false
  log_checkpoints       = false
  log_error_verbosity   = "VERBOSE"
  log_line_prefix       = "%t:%r:%u@%d:[%p]:%a:%e"

  # Guardium Configuration
  gdp_server        = "guardium.example.com"
  gdp_port          = "8443"
  gdp_username      = "admin"
  gdp_password      = var.gdp_password
  gdp_client_id     = "client1"
  gdp_client_secret = var.gdp_client_secret
  gdp_mu_host       = "guardium-mu.example.com"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| azure_region | Azure region where resources are deployed | `string` | `"eastus"` | no |
| azure_enrollment_id | Azure Enrollment ID | `string` | n/a | yes |
| resource_group_name | Name of the Azure resource group | `string` | n/a | yes |
| postgres_server_name | Name of the PostgreSQL Flexible Server | `string` | n/a | yes |
| eventhub_namespace_name | Name of the Event Hub namespace | `string` | n/a | yes |
| eventhub_name | Name of the Event Hub | `string` | n/a | yes |
| eventhub_authorization_rule_name | Name of the Event Hub authorization rule | `string` | `"RootManageSharedAccessKey"` | no |
| storage_account_name | Name of the storage account | `string` | n/a | yes |
| consumer_group | Event Hub consumer group name | `string` | `"$Default"` | no |
| diagnostic_setting_name | Name of the diagnostic setting | `string` | `"postgres-audit-to-eventhub"` | no |
| pgaudit_log | Statement classes to log | `string` | `"DDL,FUNCTION,READ,WRITE,ROLE"` | no |
| pgaudit_log_catalog | Log catalog queries | `bool` | `false` | no |
| pgaudit_log_client | Show audit messages to client | `bool` | `false` | no |
| pgaudit_log_parameter | Include parameters in log | `bool` | `false` | no |
| log_checkpoints | Log checkpoints | `bool` | `false` | no |
| log_error_verbosity | Error verbosity level | `string` | `"VERBOSE"` | no |
| log_line_prefix | Log line prefix format | `string` | `"%t:%r:%u@%d:[%p]:%a:%e"` | no |
| gdp_server | Guardium Central Manager hostname | `string` | n/a | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"` | no |
| gdp_username | Guardium Web UI username | `string` | n/a | yes |
| gdp_password | Guardium Web UI password | `string` | n/a | yes |
| gdp_client_id | Guardium OAuth client ID | `string` | n/a | yes |
| gdp_client_secret | Guardium OAuth client secret | `string` | n/a | yes |
| gdp_mu_host | Guardium Managed Units (comma-separated) | `string` | n/a | yes |
| enable_universal_connector | Enable Universal Connector module | `bool` | `true` | no |
| initial_position | Initial position for Event Hub consumer (beginning or end) | `string` | `"end"` | no |
| config_mode | Configuration mode for Event Hub input (basic or advanced) | `string` | `"basic"` | no |
| threads | Number of threads for Event Hub consumer | `number` | `8` | no |
| decorate_events | Whether to decorate events with Event Hub metadata | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| profile_csv | Universal Connector profile CSV |
| udc_name | Name of the Universal Connector |
| postgres_server_name | Name of the PostgreSQL server |
| postgres_server_endpoint | FQDN of the PostgreSQL server |
| diagnostic_setting_id | ID of the diagnostic setting |
| pgaudit_configuration | Summary of pgAudit configuration |

## pgAudit Statement Classes

The `pgaudit_log` parameter accepts the following values (comma-separated):

- **READ**: SELECT and COPY when the source is a relation or a query
- **WRITE**: INSERT, UPDATE, DELETE, TRUNCATE, and COPY when the destination is a relation
- **FUNCTION**: Function calls and DO blocks
- **ROLE**: Statements related to roles and privileges (GRANT, REVOKE, CREATE/ALTER/DROP ROLE)
- **DDL**: All DDL that is not included in the ROLE class
- **MISC**: Miscellaneous commands (DISCARD, FETCH, CHECKPOINT, VACUUM, SET)
- **ALL**: Include all of the above

## Troubleshooting

### pgAudit Not Logging

**Issue:** No audit logs appearing in Event Hub

**Solution:**
1. Verify pgAudit extension is properly configured
2. Check server parameters:
   ```sql
   SHOW shared_preload_libraries;
   SHOW pgaudit.log;
   ```
3. Verify diagnostic setting is active in Azure Portal
4. Check Event Hub for incoming messages

### Server Parameter Changes Not Applied

**Issue:** Parameter changes don't take effect

**Solution:**
1. Some parameters require server restart
2. Restart the server via Azure Portal or CLI
3. Verify changes: `SHOW <parameter_name>;`

### Connection Issues

**Issue:** Cannot connect to PostgreSQL after configuration

**Solution:**
1. Verify firewall rules allow your IP
2. Check server is in "Available" state
3. Verify connection string format
4. Ensure SSL/TLS is enabled

## Additional Resources

- [Azure PostgreSQL Flexible Server Documentation](https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/)
- [pgAudit Documentation](https://github.com/pgaudit/pgaudit)
- [PostgreSQL Logging Documentation](https://www.postgresql.org/docs/current/runtime-config-logging.html)
- [Azure Event Hubs Documentation](https://docs.microsoft.com/en-us/azure/event-hubs/)
- [Guardium Data Protection Documentation](https://www.ibm.com/docs/en/guardium)

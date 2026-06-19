# Azure MySQL Audit Configuration

This module configures audit logging for Azure MySQL Flexible Server with IBM Guardium Data Protection. It enables diagnostic settings to stream audit logs to Azure Event Hub and configures Guardium Universal Connector for log collection.

**Supported Versions:** This module requires IBM Guardium Data Protection (GDP) version **12.2.1 and above**.

## Prerequisites

Before using this module, you need to:

1. Have an existing Azure MySQL Flexible Server
2. Have Event Hub namespace and Event Hub created for audit log streaming
3. Have Storage Account created for Event Hub checkpointing
4. Have Guardium set up with appropriate credentials
5. Have Azure credentials configured in Guardium Universal Connector
6. Enable audit logging on the MySQL server (set `audit_log_enabled` parameter to `ON`)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | ~> 3.0 |
| guardium-data-protection | >= 1.0.0 |

## Features

- Configures Azure MySQL Flexible Server diagnostic settings for audit logging
- Streams audit logs to Azure Event Hub
- Supports multiple log categories:
  - MySqlAuditLogs (audit events)
  - MySqlSlowLogs (slow query logs)
- Integrates with Guardium for audit data collection via Event Hub
- Automatic Universal Connector profile deployment

## Diagnostic Setting Import Process

To ensure Terraform manages your MySQL diagnostic settings correctly:

1. Initialize Terraform in your working directory:
   ```bash
   terraform init
   ```

2. Check if diagnostic setting exists:
   ```bash
   az monitor diagnostic-settings list \
     --resource /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.DBforMySQL/flexibleServers/<mysql-server-name> \
     --query "[].name" \
     --output tsv
   ```

3. Import existing diagnostic setting (if exists):
   ```bash
   terraform import 'module.datastore-audit_azure-mysql-audit.module.common_azure-mysql-diagnostic-settings.azurerm_monitor_diagnostic_setting.mysql_audit' \
     '/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.DBforMySQL/flexibleServers/<mysql-server-name>|<diagnostic-setting-name>'
   ```

**Note**: The module includes automated diagnostic setting detection. Skipping the import step may cause Terraform to attempt creating a new diagnostic setting, which will fail if one already exists.

## Usage

### Using a tfvars File

Create a `terraform.tfvars` file with your configuration. See [terraform.tfvars.example](./terraform.tfvars.example) for an example with available options and detailed comments.

Then run:

```bash
# Import existing resources (if diagnostic setting exists)
# See the "Diagnostic Setting Import Process" section above

# Plan the changes
terraform plan

# Apply the changes
terraform apply
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

## MySQL Audit Logging

MySQL diagnostic settings capture:
- **MySqlAuditLogs**: All audit events (connections, queries, DDL, DML, DCL, admin operations)
- **MySqlSlowLogs**: Slow query logs for performance analysis

## Event Hub Integration

This module configures MySQL to send audit logs to Event Hub. The Universal Connector then:
1. Reads these logs from Event Hub using the configured Azure credentials
2. Parses and normalizes the log data
3. Forwards the processed audit events to Guardium for analysis

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| azure_region | Azure region (actual region is detected from resource group location) | `string` | `"eastus"` | no |
| resource_group_name | Name of the Azure resource group | `string` | n/a | yes |
| mysql_server_name | Name of the MySQL Flexible Server | `string` | n/a | yes |
| eventhub_namespace_name | Name of the Event Hub namespace | `string` | n/a | yes |
| eventhub_name | Name of the Event Hub | `string` | n/a | yes |
| eventhub_authorization_rule_name | Name of the Event Hub authorization rule | `string` | `"RootManageSharedAccessKey"` | no |
| storage_account_name | Name of the storage account for checkpointing | `string` | n/a | yes |
| consumer_group | Event Hub consumer group name | `string` | `"$Default"` | no |
| config_mode | Configuration mode for Event Hub input (basic or advanced) | `string` | `"basic"` | no |
| threads | Number of threads for Event Hub consumer | `number` | `8` | no |
| decorate_events | Whether to decorate events with Event Hub metadata | `bool` | `true` | no |
| enable_mysql_audit_logs | Enable MySQL Audit logs | `bool` | `true` | no |
| enable_slow_query_logs | Enable MySQL Slow Query logs | `bool` | `false` | no |
| audit_log_events | MySQL audit log events to capture (CONNECTION, GENERAL) | `string` | `"CONNECTION,GENERAL"` | no |
| gdp_server | Hostname/IP of Guardium Central Manager | `string` | n/a | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"` | no |
| gdp_username | Guardium Web UI username | `string` | n/a | yes |
| gdp_password | Guardium Web UI password | `string` | n/a | yes |
| gdp_client_id | OAuth client ID | `string` | n/a | yes |
| gdp_client_secret | OAuth client secret | `string` | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units | `string` | n/a | yes |
| enable_universal_connector | Enable Universal Connector module | `bool` | `true` | no |
| initial_position | Initial position for Event Hub consumer (beginning or end) | `string` | `"end"` | no |
| tags | Map of tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| profile_csv | Universal Connector profile CSV |
| udc_name | Name of the Universal Connector (format: `{mysql-server-name}-{subscription-id}`) |
| mysql_server_name | Name of the MySQL server |
| mysql_server_fqdn | Fully qualified domain name of the MySQL server |
| eventhub_namespace_name | Name of the Event Hub namespace |
| eventhub_name | Name of the Event Hub |
| storage_account_name | Name of the storage account |
| azure_region | Actual Azure region where the resource group is located |
| subscription_id | Azure subscription ID |
| resource_group_name | Name of the resource group |
| diagnostic_setting_name | Name of the diagnostic setting |
| diagnostic_setting_id | ID of the diagnostic setting |

## Examples

See the [examples](../../examples/azure-mysql-audit) directory for complete working examples.

## Additional Resources

- [IBM Guardium Data Protection Documentation](https://www.ibm.com/docs/en/guardium)
- [Guardium Universal Connector Guide](https://www.ibm.com/docs/en/guardium/12.2?topic=connectors-universal-connector)
- [Azure MySQL Flexible Server Audit Logs](https://docs.microsoft.com/en-us/azure/mysql/flexible-server/concepts-audit-logs)
- [Azure Event Hubs Documentation](https://docs.microsoft.com/en-us/azure/event-hubs/)
- [Azure MySQL Guardium Filter Plugin](https://github.com/IBM/universal-connectors/tree/main/filter-plugin/logstash-filter-mysql-azure-guardium)

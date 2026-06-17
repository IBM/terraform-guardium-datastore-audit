# Azure MySQL Audit Configuration

This module configures audit logging for Azure MySQL Flexible Server with IBM Guardium Data Protection. It enables diagnostic settings to stream audit logs to Azure Event Hub and configures Guardium Universal Connector for log collection.

**Supported Versions:** This module requires IBM Guardium Data Protection (GDP) version **12.2.2 and above**.

## Prerequisites

Before using this module, you need to:

1. **Azure CLI Authentication**: Be authenticated with Azure CLI (`az login`)
2. Have an existing Azure MySQL Flexible Server
3. Have Event Hub namespace and Event Hub created for audit log streaming
4. Have Storage Account created for Event Hub checkpointing
5. Have Guardium set up with appropriate credentials
6. Have Azure credentials configured in Guardium Universal Connector
7. Enable audit logging on the MySQL server (set `audit_log_enabled` parameter to `ON`)

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

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│              Azure MySQL Flexible Server                    │
│                                                             │
│  • MySqlAuditLogs (audit events)                            │
│  • MySqlSlowLogs (slow queries)                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ Diagnostic Settings
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│              Azure Event Hub                                │
│                                                             │
│  • Namespace: <eventhub-namespace>                          │
│  • Event Hub: <eventhub-name>                               │
│  • Consumer Group: $Default                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ Event Streaming
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│         Guardium Universal Connector (UC)                   │
│                                                             │
│  • Reads events from Event Hub                              │
│  • Parses and normalizes audit data                         │
│  • Applies security policies                                │
│  • Forwards to Guardium Data Protection                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ Processed Audit Data
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│         Guardium Data Protection (GDP)                      │
│                                                             │
│  • Security monitoring and threat detection                 │
│  • Compliance reporting and auditing                        │
│  • Policy enforcement and alerting                          │
│  • Activity analysis and forensics                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Usage

### Basic Example

```hcl
module "mysql_audit" {
  source = "IBM/datastore-audit/guardium//modules/azure-mysql-audit"

  # Azure Configuration
  azure_region         = "eastus"
  resource_group_name  = "my-resource-group"
  mysql_server_name    = "my-mysql-server"
  
  # Event Hub Configuration
  eventhub_namespace_name = "my-eventhub-namespace"
  eventhub_name           = "mysql-audit-logs"
  storage_account_name    = "mystorageaccount"
  
  # Guardium Configuration
  gdp_server             = "guardium.example.com"
  gdp_port               = "8443"
  gdp_username           = "admin"
  gdp_password           = "password"
  gdp_client_id          = "client1"
  gdp_client_secret      = "client-secret"
  gdp_mu_host            = "guardium-mu.example.com"
  
  tags = {
    Environment = "production"
    Project     = "data-security"
  }
}
```

### Advanced Example with Custom Log Categories

```hcl
module "mysql_audit" {
  source = "IBM/datastore-audit/guardium//modules/azure-mysql-audit"

  # Azure Configuration
  azure_region         = "eastus"
  resource_group_name  = "my-resource-group"
  mysql_server_name    = "my-mysql-server"
  
  # Event Hub Configuration
  eventhub_namespace_name          = "my-eventhub-namespace"
  eventhub_name                    = "mysql-audit-logs"
  eventhub_authorization_rule_name = "my-auth-rule"
  storage_account_name             = "mystorageaccount"
  consumer_group                   = "$Default"
  
  # Diagnostic Settings - Enable specific log categories
  enable_mysql_audit_logs = true   # Audit events
  enable_slow_query_logs  = true   # Slow queries
  
  # Guardium Configuration
  gdp_server             = "guardium.example.com"
  gdp_port               = "8443"
  gdp_username           = "admin"
  gdp_password           = "password"
  gdp_client_id          = "client1"
  gdp_client_secret      = "client-secret"
  gdp_mu_host            = "guardium-mu.example.com"
  
  # Universal Connector Configuration
  csv_start_position   = "end"
  csv_interval         = "5"
  
  tags = {
    Environment = "production"
    Project     = "data-security"
  }
}
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| azure_region | Azure region where resources are deployed | `string` | `"eastus"` | no |
| resource_group_name | Name of the Azure resource group | `string` | n/a | yes |
| mysql_server_name | Name of the MySQL Flexible Server | `string` | n/a | yes |
| eventhub_namespace_name | Name of the Event Hub namespace | `string` | n/a | yes |
| eventhub_name | Name of the Event Hub | `string` | n/a | yes |
| eventhub_authorization_rule_name | Name of the Event Hub authorization rule | `string` | `"RootManageSharedAccessKey"` | no |
| storage_account_name | Name of the storage account for checkpointing | `string` | n/a | yes |
| consumer_group | Event Hub consumer group name | `string` | `"$Default"` | no |
| enable_mysql_audit_logs | Enable MySQL Audit logs | `bool` | `true` | no |
| enable_slow_query_logs | Enable MySQL Slow Query logs | `bool` | `false` | no |
| gdp_server | Hostname/IP of Guardium Central Manager | `string` | n/a | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"` | no |
| gdp_username | Guardium Web UI username | `string` | n/a | yes |
| gdp_password | Guardium Web UI password | `string` | n/a | yes |
| gdp_client_id | OAuth client ID | `string` | n/a | yes |
| gdp_client_secret | OAuth client secret | `string` | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units | `string` | n/a | yes |
| enable_universal_connector | Enable Universal Connector module | `bool` | `true` | no |
| csv_start_position | Start position for UDC (beginning or end) | `string` | `"end"` | no |
| csv_interval | Polling interval for UDC in seconds | `string` | `"5"` | no |
| tags | Map of tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| profile_csv | Universal Connector profile CSV |
| udc_name | Name of the Universal Connector |
| mysql_server_name | Name of the MySQL server |
| mysql_server_fqdn | Fully qualified domain name of the MySQL server |
| eventhub_namespace_name | Name of the Event Hub namespace |
| eventhub_name | Name of the Event Hub |
| storage_account_name | Name of the storage account |
| azure_region | Azure region where resources are deployed |
| subscription_id | Azure subscription ID |
| resource_group_name | Name of the resource group |
| diagnostic_setting_name | Name of the diagnostic setting |
| diagnostic_setting_id | ID of the diagnostic setting |

## Log Categories

### MySqlAuditLogs
Captures MySQL audit events including:
- Connection events (login/logout)
- Query executions
- DDL operations (CREATE, ALTER, DROP)
- DML operations (INSERT, UPDATE, DELETE, SELECT)
- DCL operations (GRANT, REVOKE)
- Administrative commands

### MySqlSlowLogs
Provides slow query logs:
- Queries exceeding the configured slow query threshold
- Query execution time
- Rows examined and returned
- Lock time

## MySQL Server Configuration

To enable audit logging on your MySQL Flexible Server, you need to configure the following server parameters:

```hcl
resource "azurerm_mysql_flexible_server_configuration" "audit_log_enabled" {
  name                = "audit_log_enabled"
  resource_group_name = var.resource_group_name
  server_name         = var.mysql_server_name
  value               = "ON"
}

resource "azurerm_mysql_flexible_server_configuration" "audit_log_events" {
  name                = "audit_log_events"
  resource_group_name = var.resource_group_name
  server_name         = var.mysql_server_name
  value               = "CONNECTION,DML,DDL,DCL,ADMIN"
}
```

## Security Considerations

- **Credentials Management**: Store sensitive credentials securely using Terraform variables or secret management solutions
- **State File Security**: Ensure Terraform state files are encrypted and stored securely
- **Network Security**: Configure network security groups and firewall rules appropriately
- **Encryption**: Enable encryption for Event Hub and data in transit
- **Access Control**: Implement proper access controls for Guardium and Azure resources
- **Event Hub Authorization**: Use dedicated authorization rules with minimal required permissions

## Troubleshooting

### Common Issues

1. **Diagnostic Settings Not Streaming Logs**:
   - Verify Event Hub namespace and Event Hub exist
   - Check Event Hub authorization rule has appropriate permissions
   - Ensure MySQL server has diagnostic settings enabled
   - Verify audit logging is enabled on MySQL server (`audit_log_enabled = ON`)
   - Review Azure Monitor diagnostic settings in Azure Portal

2. **Universal Connector Not Processing Logs**:
   - Verify Azure credentials are correctly configured in Guardium
   - Check network connectivity between Guardium and Azure
   - Review Universal Connector logs in Guardium UI
   - Verify Event Hub consumer group is accessible

3. **Authentication Errors**:
   - Verify Guardium OAuth client credentials
   - Check Guardium user has appropriate permissions
   - Ensure OAuth client is properly registered via `grdapi register_oauth_client`
   - Verify Azure credential is configured in Guardium

4. **Missing Audit Logs**:
   - Check which log categories are enabled
   - Verify diagnostic settings are applied to the correct MySQL server
   - Review Event Hub metrics for incoming messages
   - Check storage account for checkpoint data
   - Ensure MySQL audit logging is properly configured

## Examples

See the [examples](../../examples/azure-mysql-audit) directory for complete working examples.

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](../../LICENSE) file for details.

```text
#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#
```

## Additional Resources

- [IBM Guardium Data Protection Documentation](https://www.ibm.com/docs/en/guardium)
- [Guardium Universal Connector Guide](https://www.ibm.com/docs/en/guardium/12.2?topic=connectors-universal-connector)
- [Azure MySQL Flexible Server Audit Logs](https://docs.microsoft.com/en-us/azure/mysql/flexible-server/concepts-audit-logs)
- [Azure Event Hubs Documentation](https://docs.microsoft.com/en-us/azure/event-hubs/)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure MySQL Guardium Filter Plugin](https://github.com/IBM/universal-connectors/tree/main/filter-plugin/logstash-filter-mysql-azure-guardium)

## Module Architecture

This module uses two common sub-modules:
- `azure-mysql-diagnostic-settings` - Configures MySQL-specific diagnostic settings
- `azure-eventhub-registration` - Generic EventHub registration module (shared with other Azure services)
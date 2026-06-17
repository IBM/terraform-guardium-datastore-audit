# On-Premises Couchbase Audit Module

This Terraform module configures audit logging and Filebeat for on-premises Couchbase databases to forward audit logs to IBM Guardium Data Protection.

## Features

- **Automated Audit Logging Configuration**: Enables Couchbase audit logging via REST API
- **Filebeat Setup**: Configures Filebeat to forward Couchbase audit logs to Guardium
- **Universal Connector Integration**: Creates and configures Guardium Universal Connector
- **Flexible Configuration**: Supports customizable audit log rotation and retention settings

## Prerequisites

1. **Couchbase Server**: On-premises Couchbase installation with web console access
2. **SSH Access**: SSH credentials to the Couchbase server
3. **Filebeat**: Filebeat must be installed on the Couchbase server
4. **Guardium**: IBM Guardium Data Protection with Universal Connector capability
5. **Network Connectivity**: Couchbase server must be able to reach Guardium Managed Unit

## Couchbase Audit Logging

This module automates the audit logging configuration described in the Couchbase documentation:

1. Enables audit logging via REST API
2. Configures audit log directory (default: `/opt/couchbase/var/lib/couchbase/logs`)
3. Sets log rotation interval (default: 24 hours)
4. Sets log rotation size (default: 20 MB)
5. Enables Data Service and Query/Index Service audit events
6. Filters out extraneous events (select bucket, /admin/stats API)

## Usage

```hcl
provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}

module "couchbase_audit" {
  source = "../../modules/onprem-couchbase"

  # Couchbase Instance Configuration
  couchbase_instance_identifier = "prod-couchbase-01"
  couchbase_host                = "10.0.1.50"
  couchbase_port                = "8091"
  couchbase_cluster_name        = "production-cluster"
  couchbase_admin_username      = "Administrator"
  couchbase_admin_password      = var.couchbase_admin_password
  couchbase_audit_log_directory = "/opt/couchbase/var/lib/couchbase/logs"
  
  # Audit Configuration
  enable_audit_logging      = true
  audit_log_rotate_interval = 86400  # 24 hours
  audit_log_rotate_size     = 20     # 20 MB

  # Filebeat Configuration
  enable_filebeat_setup = true
  server_ip             = "10.0.1.50"
  server_username       = "ubuntu"
  server_password       = var.server_password
  logstash_port         = "5044"
  datasource_tag        = "couchbase-prod"

  # Guardium Configuration
  udc_name          = "couchbase-prod-connector"
  gdp_client_id     = var.gdp_client_id
  gdp_client_secret = var.gdp_client_secret
  gdp_server        = var.gdp_server
  gdp_port          = var.gdp_port
  gdp_username      = var.gdp_username
  gdp_password      = var.gdp_password
  gdp_mu_host       = var.gdp_mu_host

  # Universal Connector Configuration
  enable_universal_connector = true

  # Tags
  tags = {
    Environment = "production"
    Application = "couchbase"
  }
}
```

## Audit Logging Configuration Steps

The module performs the following steps to enable audit logging:

1. **Enable Audit Logging**: Uses Couchbase REST API to enable audit logging
2. **Configure Log Directory**: Sets the directory where audit logs are stored
3. **Set Rotation Policy**: Configures time-based and size-based log rotation
4. **Enable Audit Events**: Enables Data Service and Query/Index Service events
5. **Filter Events**: Disables extraneous events to reduce noise

## Filebeat Configuration

The module configures Filebeat with:

- **Input Type**: `filestream` for efficient log tailing
- **Log Path**: Monitors `audit.log` in the configured directory
- **JSON Parsing**: Parses Couchbase JSON audit log format
- **Tagging**: Adds datasource tag for identification in Guardium
- **Output**: Sends logs to Guardium Logstash endpoint

## Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `couchbase_instance_identifier` | Unique identifier for the Couchbase instance | `string` |
| `couchbase_host` | Hostname or IP address of the Couchbase server | `string` |
| `logstash_port` | Port number for Logstash on Guardium server | `string` |
| `datasource_tag` | Datasource tag for identifying the instance in Guardium | `string` |
| `gdp_client_id` | Client ID for Guardium OAuth | `string` |
| `gdp_client_secret` | Client secret for Guardium OAuth | `string` |
| `gdp_server` | Hostname/IP of Guardium Central Manager | `string` |
| `gdp_username` | Guardium Web UI username | `string` |
| `gdp_password` | Guardium Web UI password | `string` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `couchbase_port` | Couchbase web console port | `string` | `"8091"` |
| `couchbase_cluster_name` | Name of the Couchbase cluster | `string` | `""` |
| `couchbase_admin_username` | Couchbase admin username | `string` | `""` |
| `couchbase_admin_password` | Couchbase admin password | `string` | `""` |
| `couchbase_audit_log_directory` | Audit log directory path | `string` | `"/opt/couchbase/var/lib/couchbase/logs"` |
| `enable_audit_logging` | Enable audit logging configuration | `bool` | `true` |
| `audit_log_rotate_interval` | Log rotation interval in seconds (900-604800) | `number` | `86400` |
| `audit_log_rotate_size` | Log rotation size in MB | `number` | `20` |
| `enable_filebeat_setup` | Enable Filebeat configuration | `bool` | `true` |
| `server_ip` | IP address for SSH connection | `string` | `""` |
| `server_username` | Username for SSH connection | `string` | `""` |
| `server_password` | Password for SSH connection | `string` | `""` |
| `enable_universal_connector` | Enable Universal Connector creation | `bool` | `true` |
| `udc_name` | Universal Connector name | `string` | `""` (auto-generated) |
| `csv_description` | UDC connector description | `string` | `""` (auto-generated) |
| `gdp_port` | Guardium Central Manager port | `string` | `"8443"` |
| `gdp_mu_host` | Guardium Managed Units (comma-separated) | `string` | `""` |
| `tags` | Resource tags | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `udc_name` | Name of the Universal Connector created |
| `couchbase_instance_identifier` | Identifier of the Couchbase instance |
| `audit_logging_enabled` | Whether audit logging was enabled |
| `filebeat_configured` | Whether Filebeat was configured |
| `universal_connector_enabled` | Whether Universal Connector was created |
| `couchbase_audit_log_directory` | Directory where audit logs are stored |

## Notes

- **Audit Log Rotation**: The default rotation interval is 24 hours (86400 seconds) and size is 20 MB
- **REST API Access**: Requires Couchbase administrator credentials for audit configuration
- **SSH Access**: Requires SSH access to the Couchbase server for Filebeat setup
- **Filebeat Installation**: Filebeat must be pre-installed on the Couchbase server
- **Network Requirements**: Couchbase server must be able to reach Guardium on the configured Logstash port

## Troubleshooting

### Audit Logging Not Enabled

Check Couchbase web console (Settings > Audit) or use REST API:
```bash
curl -X GET http://localhost:8091/settings/audit -u Administrator:password
```

### Filebeat Not Running

Check Filebeat status:
```bash
sudo systemctl status filebeat
```

View Filebeat logs:
```bash
sudo journalctl -u filebeat -f
```

### No Logs in Guardium

1. Verify Filebeat is sending logs: Check `/var/log/filebeat/filebeat` log file
2. Verify network connectivity: Test connection to Guardium Logstash port
3. Verify Universal Connector: Check Guardium web console for connector status

## License

Copyright IBM Corp. 2026  
SPDX-License-Identifier: Apache-2.0
# MySQL Syslog Configuration

This module configures syslog-based audit logging for on-premises MySQL instances on Linux with IBM Guardium Data Protection. It automates the installation and configuration of MySQL audit plugin and enables MySQL to send audit logs via syslog protocol directly to Guardium for monitoring and analysis.

**Supported Versions:** This module requires IBM Guardium Data Protection (GDP) version **12.2.1 and above**.

## Platform Support

This module supports **Linux** MySQL installations and automatically configures audit logging via my.cnf modification and systemd service management.

## Prerequisites

Before using this module, you need to:

1. Have an on-premises MySQL instance on Linux
2. SSH access to the MySQL server
3. MySQL root password
4. Have Guardium set up with appropriate credentials
5. Network connectivity between MySQL server and Guardium

## Usage

### Enable Audit Logging (Default)

By default, the module will install and configure MySQL audit logging. Set `enable_audit_log = true` (default) to enable this feature.

### Skip Audit Setup (Connector Only)

If your MySQL server already has audit logging configured, you can skip the audit setup and only configure the Guardium connector by setting `enable_audit_log = false`.

### Linux MySQL Server

```hcl
module "mysql_audit_linux" {
  source = "IBM/datastore-audit/guardium//modules/mysql-syslog"

  # MySQL Instance Configuration
  mysql_instance_identifier = "my-mysql-linux"
  mysql_host                = "mysql-server.example.com"
  mysql_port                = "3306"

  # Audit Configuration
  enable_audit_log = true  # Set to false to skip audit setup

  # Server Connection (SSH)
  server_ip           = "192.168.1.101"
  server_username     = "ubuntu"
  server_password     = var.server_password
  mysql_root_password = var.mysql_root_password

  # Guardium Configuration
  gdp_server        = "guardium.example.com"
  gdp_port          = "8443"
  gdp_username      = "admin"
  gdp_password      = var.gdp_password
  gdp_client_id     = "client1"
  gdp_client_secret = var.gdp_client_secret
  gdp_mu_host       = "guardium-mu.example.com"

  # Syslog Configuration
  syslog_port = "5000"
  ssl_enable  = true
  ssl_verify  = true
}
```

## What This Module Does

### For Linux Servers

1. **Installs Audit Plugin**: Runs the audit_log_filter_linux_install.sql script
2. **Verifies Installation**: Checks that the audit plugin is active
3. **Backs up my.cnf**: Creates a backup of the MySQL configuration file
4. **Configures Audit Plugin**: Adds the following to /etc/my.cnf:
   ```ini
   plugin-load = audit_log.so
   audit_log_format=JSON
   audit-log=FORCE_PLUS_PERMANENT
   port=5143
   ```
5. **Configures rsyslog**: Sets up rsyslog to forward MySQL audit logs to Guardium
6. **Restarts MySQL Service**: Restarts mysqld via systemctl
7. **Enables Audit Filters**: Creates and assigns the 'log_all' filter to capture all database activity
8. **Configures Universal Connector**: Sets up Guardium Universal Connector to receive audit logs via syslog
9. **Streams to Guardium**: Audit data flows to Guardium Data Protection for monitoring and compliance


## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| guardium-data-protection | >= 1.0.0 |

## Features

- Configures Guardium to receive MySQL audit logs via syslog
- Supports both TCP and UDP syslog protocols
- Supports RFC3164 and RFC5424 syslog formats
- SSL/TLS encryption support for secure syslog transmission
- Configurable Logstash input with custom Grok patterns
- Integrates with Guardium Universal Connector for audit data collection
- Uses `mysql_filter_guardium` Logstash filter for audit processing

## Logstash Configuration

This module configures a Logstash-based Universal Connector with the following components:

### Input Configuration
- **TCP/UDP listener**: Receives syslog messages from MySQL
- **SSL/TLS support**: Secure encrypted communication
- **Configurable port**: Default 5000, customizable
- **DNS reverse lookup**: Optional, disabled by default for performance

### Filter Configuration
- **Grok parsing**: Extracts structured data from syslog messages
- **Default pattern**: `%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:server_hostname} %{SYSLOGPROG:source_program}(?:[%{POSINT:syslog_pid}])?: %{GREEDYDATA:mysql_message}`
- **Custom patterns**: Support for custom Grok patterns
- **MySQL filter**: Uses `mysql_filter_guardium{}` plugin for Guardium-specific processing
- **Field cleanup**: Removes unnecessary fields after processing

## MySQL Syslog Configuration

Before using this module, ensure your MySQL instance is configured to send audit logs via syslog. This typically involves:

1. Installing and enabling the MySQL audit plugin
2. Configuring the audit plugin to use syslog output
3. Setting the appropriate syslog facility and priority

Example MySQL configuration:
```sql
INSTALL PLUGIN audit_log SONAME 'audit_log.so';
SET GLOBAL audit_log_handler = 'SYSLOG';
SET GLOBAL audit_log_syslog_facility = 'LOG_LOCAL0';
SET GLOBAL audit_log_syslog_priority = 'LOG_INFO';
```

## Usage

### Using a tfvars File

Create a `defaults.tfvars` file with your configuration:

```hcl
# MySQL Instance Configuration
mysql_instance_identifier = "prod-mysql-01"
mysql_host                = "192.168.1.100"
mysql_port                = "3306"

# Guardium Configuration
gdp_server        = "guardium.example.com"
gdp_port          = "8443"
gdp_username      = "admin"
gdp_password      = "your-password"
gdp_client_id     = "your-client-id"
gdp_client_secret = "your-client-secret"
gdp_mu_host       = "guardium-mu-01"

# Syslog Configuration
syslog_protocol = "TCP"
syslog_format   = "RFC5424"

# Universal Connector Configuration
udc_name                   = "mysql-prod-syslog"
enable_universal_connector = true

# Tags
tags = {
  Environment = "production"
  Application = "mysql-audit"
}
```

Then run:

```bash
# Initialize Terraform
terraform init

# Plan the changes
terraform plan -var-file=defaults.tfvars

# Apply the changes
terraform apply -var-file=defaults.tfvars
```

## Provider Configuration

This module requires the Guardium Data Protection provider:

```hcl
provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}
```

### Provider Authentication

The Guardium Data Protection provider is sourced from IBM's internal Artifactory:
```
na.artifactory.swg-devops.com/ibm/guardium-data-protection
```

**Authentication Setup:**

1. Create a `~/.terraformrc` file with your Artifactory credentials:
```hcl
credentials "na.artifactory.swg-devops.com" {
  token = "YOUR_ARTIFACTORY_TOKEN"
}
```

2. Or set environment variables:
```bash
export TF_TOKEN_na_artifactory_swg_devops_com="YOUR_ARTIFACTORY_TOKEN"
```

3. Obtain your Artifactory token from: https://na.artifactory.swg-devops.com/

**Note:** If you don't have access to IBM's internal Artifactory, contact your Guardium administrator for credentials.

## Module Dependencies

This module uses the following internal module:

1. `mysql-syslog-registration` - Configures Guardium to receive and process MySQL syslog audit logs

## Syslog Protocol Options

The module supports two syslog protocols:

- **TCP**: Reliable, connection-oriented protocol. Recommended for production environments.
- **UDP**: Connectionless protocol. Faster but may lose messages under high load.

## Syslog Format Options

The module supports two syslog message formats:

- **RFC5424**: Modern syslog format with structured data. Recommended for new deployments.
- **RFC3164**: Legacy BSD syslog format. Use if your MySQL version only supports this format.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| mysql_instance_identifier | Unique identifier for the MySQL instance | string | n/a | yes |
| mysql_host | Hostname or IP address of the MySQL server | string | n/a | yes |
| mysql_port | Port number of the MySQL server | string | `"3306"` | no |
| gdp_client_secret | Client secret from Guardium | string | n/a | yes |
| gdp_client_id | Client ID from Guardium | string | n/a | yes |
| gdp_server | Guardium server hostname/IP | string | n/a | yes |
| gdp_port | Port of Guardium Central Manager | string | `"8443"` | no |
| gdp_username | Guardium username | string | n/a | yes |
| gdp_password | Guardium password | string | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units | string | `""` | no |
| udc_name | Name for universal connector. If not provided, will be auto-generated | string | `""` | no |
| enable_universal_connector | Whether to enable the universal connector | bool | `true` | no |
| syslog_port | Port number for Logstash to listen for syslog messages | string | `"5000"` | no |
| syslog_protocol | Syslog protocol to use (TCP or UDP) | string | `"TCP"` | no |
| syslog_format | Syslog message format (RFC3164 or RFC5424) | string | `"RFC5424"` | no |
| ssl_enable | Enable SSL/TLS for syslog connection | bool | `true` | no |
| ssl_cert_path | Path to SSL certificate file | string | `"/service/certs/external/tls-syslog.crt"` | no |
| ssl_key_path | Path to SSL private key file | string | `"/service/certs/external/tls-syslog.key"` | no |
| ssl_verify | Enable SSL certificate verification | bool | `true` | no |
| dns_reverse_lookup_enabled | Enable DNS reverse lookup for incoming connections | bool | `false` | no |
| logstash_grok_pattern | Custom Grok pattern for parsing MySQL syslog messages | string | `""` | no |
| tags | Map of tags to apply to resources | map(string) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| udc_name | Name of the Universal Connector |
| mysql_instance_identifier | MySQL instance identifier |
| mysql_host | MySQL server hostname/IP |
| mysql_port | MySQL server port |
| syslog_protocol | Syslog protocol being used |
| syslog_format | Syslog message format being used |

## Troubleshooting

### Syslog Messages Not Reaching Guardium

1. Verify network connectivity between MySQL server and Guardium
2. Check firewall rules allow syslog traffic (typically port 514 for UDP, 601 or 6514 for TCP)
3. Verify MySQL audit plugin is properly configured and enabled
4. Check Guardium logs for any connection or parsing errors

### Audit Logs Not Appearing in Guardium

1. Verify the Universal Connector is enabled and running
2. Check that the syslog format matches what MySQL is sending
3. Verify Guardium has proper credentials and permissions
4. Review Guardium audit policy configuration

## Security Considerations

- Use TCP protocol for production environments to ensure reliable log delivery
- Secure the syslog communication channel (consider using TLS if supported)
- Regularly rotate Guardium credentials
- Implement proper network segmentation between MySQL and Guardium
- Monitor for any gaps in audit log collection

## License

Copyright IBM Corp. 2025
SPDX-License-Identifier: Apache-2.0
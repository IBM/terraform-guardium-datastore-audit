# Apache Cassandra Audit Module

This Terraform module automates the configuration of Apache Cassandra audit log forwarding to Guardium Data Protection using Filebeat. This module configures Filebeat only; you must enable Cassandra audit logging separately before running Terraform.

## Overview

This module:
1. Configures Filebeat on the Cassandra server to collect Cassandra audit logs
2. Forwards audit logs to Guardium via Logstash
3. Registers the Cassandra instance as a Universal Connector datasource in Guardium
4. Does not enable Cassandra audit logging in Cassandra itself

## Prerequisites

- Apache Cassandra instance
- Cassandra audit logging enabled before running this module
- Filebeat installed on the Cassandra server
- SSH access to the Cassandra server
- Guardium Data Protection instance with Universal Connector configured
- OAuth client registered in Guardium (using `grdapi register_oauth_client`)

## Cassandra Audit Configuration

This module enables Filebeat log collection only. It does **not** enable Cassandra audit logging for you. Before using this module, explicitly enable Cassandra audit logging on the Cassandra server.

### Steps to enable Cassandra audit logging

1. Edit `/etc/cassandra/conf/cassandra.yaml`.
2. In `audit_logging_options`, change `enabled: false` to `enabled: true`.
3. Set the logger class to `FileAuditLogger`.
4. Edit `/etc/cassandra/conf/logback.xml`.
5. Uncomment the `AUDIT` appender and `org.apache.cassandra.audit` logger configuration shown below.
6. Save the files.
7. Restart the Cassandra service.

#### Example `cassandra.yaml` configuration

```yaml
audit_logging_options:
    enabled: true
    logger:
      - class_name: FileAuditLogger
    audit_logs_dir: /var/log/cassandra/audit
    included_keyspaces: ""
    excluded_keyspaces: "system,system_schema,system_virtual_schema"
    included_categories: ""
    excluded_categories: ""
    included_users: ""
    excluded_users: ""
```

#### Example `logback.xml` configuration

```xml
<appender name="AUDIT" class="ch.qos.logback.core.rolling.RollingFileAppender">
  <file>${cassandra.logdir}/audit/audit.log</file>
  <rollingPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy">
    <!-- rollover daily -->
    <fileNamePattern>${cassandra.logdir}/audit/audit.log.%d{yyyy-MM-dd}.%i.zip</fileNamePattern>
    <!-- each file should be at most 50MB, keep 30 days worth of history, but at most 5GB -->
    <maxFileSize>50MB</maxFileSize>
    <maxHistory>30</maxHistory>
    <totalSizeCap>5GB</totalSizeCap>
  </rollingPolicy>
  <encoder>
    <pattern>%-5level [%thread] %date{ISO8601} %F:%L - %msg%n</pattern>
  </encoder>
</appender>

<!-- Audit Logging additivity to redirect audit logging events to audit/audit.log -->
<logger name="org.apache.cassandra.audit" additivity="false" level="INFO">
  <appender-ref ref="AUDIT"/>
</logger>
```

After saving the files, restart Cassandra:

```bash
sudo systemctl restart cassandra
```

## Usage

```hcl
module "cassandra_audit" {
  source = "path/to/modules/onprem-cassandra"

  # Cassandra Configuration
  # Audit logging must already be enabled in cassandra.yaml and logback.xml
  cassandra_instance_identifier = "prod-cassandra-01"
  cassandra_host                = "10.0.1.100"
  cassandra_audit_log_path      = "/var/log/cassandra/audit/audit.log"

  # Filebeat Setup (SSH connection to Cassandra server)
  enable_filebeat_setup = true
  server_ip             = "10.0.1.100"
  server_username       = "cassandra"
  server_password       = var.cassandra_server_password

  # Guardium Configuration
  gdp_server        = "guardium.example.com"
  gdp_port          = "8443"
  gdp_username      = "admin"
  gdp_password      = var.gdp_password
  gdp_client_id     = "client4"
  gdp_client_secret = var.gdp_client_secret
  gdp_mu_host       = "guardium-mu-01.example.com"

  # Logstash Configuration
  logstash_port = "5044"
  ssl_enable    = true
  ssl_verify    = true
}
```

## Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `cassandra_instance_identifier` | Unique identifier for the Cassandra instance | `string` |
| `cassandra_host` | Hostname or IP address of the Cassandra server | `string` |
| `gdp_server` | Hostname/IP address of Guardium Central Manager | `string` |
| `gdp_username` | Username of Guardium Web UI user | `string` |
| `gdp_password` | Password of Guardium Web UI user | `string` |
| `gdp_client_id` | Client ID used when running grdapi register_oauth_client | `string` |
| `gdp_client_secret` | Client secret from output of grdapi register_oauth_client | `string` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `cassandra_audit_log_path` | Path to Cassandra audit log file | `string` | `/var/log/cassandra/audit/audit.log` |
| `logstash_port` | Port number for Logstash on Guardium server | `string` | `5044` |
| `enable_filebeat_setup` | Enable Filebeat configuration on Cassandra server | `bool` | `true` |
| `enable_universal_connector` | Enable the universal connector module | `bool` | `true` |
| `ssl_enable` | Enable SSL/TLS for Filebeat to Logstash connection | `bool` | `true` |
| `ssl_verify` | Enable SSL certificate verification | `bool` | `true` |
| `gdp_port` | Port of Guardium Central Manager | `string` | `8443` |
| `gdp_mu_host` | Comma separated list of Guardium Managed Units | `string` | `""` |

## Outputs

| Name | Description |
|------|-------------|
| `udc_name` | Name of the Universal Connector created |
| `cassandra_instance_identifier` | Identifier of the Cassandra instance |
| `filebeat_configured` | Whether Filebeat was configured |
| `universal_connector_enabled` | Whether the Universal Connector was created |

## Notes

- The module uses SSH to configure Filebeat on the Cassandra server
- Ensure Cassandra audit logging is enabled in both `cassandra.yaml` and `logback.xml` before running this module
- Ensure the Cassandra server has Filebeat installed before running this module
- The module creates a backup of the existing `filebeat.yml` before modification
- SSL/TLS is recommended for production environments

## License

Copyright IBM Corp. 2026
SPDX-License-Identifier: Apache-2.0
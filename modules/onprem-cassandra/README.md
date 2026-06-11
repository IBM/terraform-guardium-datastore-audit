# Apache Cassandra Audit Module

This module configures Filebeat for Apache Cassandra audit logs and registers the datasource with Guardium.

## What this module does

Use this module with an existing on-premises Cassandra deployment.

It:
- configures Filebeat on the Cassandra server over SSH
- backs up the existing `/etc/filebeat/filebeat.yml`
- writes a Filebeat configuration for the Cassandra audit log path
- tests the Filebeat configuration
- restarts and enables the Filebeat service
- registers the Cassandra datasource with Guardium Universal Connector

It does not enable Cassandra audit logging in `cassandra.yaml`.

## Prerequisites

You need:
- an existing Apache Cassandra server
- Cassandra audit logging already enabled
- Filebeat installed on the Cassandra server
- SSH access to the Cassandra server
- network connectivity from the Cassandra server to Guardium Logstash
- Guardium OAuth client credentials and Web UI credentials

## Cassandra audit logging

Before using this module, enable Cassandra audit logging in `cassandra.yaml`:

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

After updating `cassandra.yaml`, restart Cassandra so audit logging takes effect:

```bash
sudo systemctl restart cassandra
```

## Usage

```hcl
module "cassandra_audit" {
  source = "path/to/modules/onprem-cassandra"

  cassandra_instance_identifier = "prod-cassandra-01"
  cassandra_host                = "10.0.1.100"
  cassandra_audit_log_path      = "/var/log/cassandra/audit/audit.log"

  enable_filebeat_setup = true
  server_ip             = "10.0.1.100"
  server_username       = "cassandra"
  server_password       = var.cassandra_server_password

  gdp_server        = "guardium.example.com"
  gdp_port          = "8443"
  gdp_username      = "admin"
  gdp_password      = var.gdp_password
  gdp_client_id     = "client4"
  gdp_client_secret = var.gdp_client_secret
  gdp_mu_host       = "guardium-mu-01.example.com"

  logstash_port = "5044"
  ssl_enable    = true
  ssl_verify    = true
}
```

## Key inputs

Required:
- `cassandra_instance_identifier`
- `cassandra_host`
- `gdp_server`
- `gdp_username`
- `gdp_password`
- `gdp_client_id`
- `gdp_client_secret`

Common optional inputs:
- `cassandra_audit_log_path` default: `/var/log/cassandra/audit/audit.log`
- `enable_filebeat_setup` default: `true`
- `logstash_port` default: `5044`
- `enable_universal_connector` default: `true`
- `ssl_enable` default: `true`
- `ssl_verify` default: `true`
- `gdp_port` default: `8443`
- `gdp_mu_host` default: empty

## Outputs

- `udc_name`
- `cassandra_instance_identifier`
- `filebeat_configured`
- `universal_connector_enabled`

## Verify

### Check Cassandra audit logs

```bash
ls -lh /var/log/cassandra/audit/
tail -f /var/log/cassandra/audit/audit.log
```

### Check Filebeat

```bash
sudo systemctl status filebeat
sudo filebeat test config -c /etc/filebeat/filebeat.yml
```

### Check Guardium

In Guardium, verify the Universal Connector is running and receiving Cassandra audit data.

## Troubleshooting

### No logs in Guardium
- confirm Cassandra audit logging is enabled in `cassandra.yaml`
- confirm Cassandra was restarted after enabling audit logging
- confirm Filebeat is installed and running
- confirm the audit log path is correct
- confirm the Cassandra server can reach Guardium Logstash

### Filebeat issues
- check `/var/log/filebeat/filebeat`
- check `sudo journalctl -u filebeat -f`
- verify Filebeat can read the Cassandra audit log file

## License

Copyright IBM Corp. 2026
SPDX-License-Identifier: Apache-2.0
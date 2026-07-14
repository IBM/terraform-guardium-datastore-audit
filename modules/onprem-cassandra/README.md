# Apache Cassandra Audit Module

This Terraform module automates the configuration of Apache Cassandra audit log forwarding to Guardium Data Protection using Filebeat. This module configures Filebeat only; you must enable Cassandra audit logging separately before running Terraform.

## What this module does

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
- network connectivity from the Cassandra server to Guardium Logstash
- Guardium OAuth client credentials and Web UI credentials

## Cassandra audit logging

This module enables Filebeat log collection only. It does **not** enable Cassandra audit logging for you. Before using this module, you must enable Cassandra audit logging on the Cassandra server.

For detailed instructions on enabling Cassandra audit logging, see the [Cassandra Guardium documentation](https://github.com/IBM/universal-connectors/blob/main/filter-plugin/logstash-filter-cassandra-guardium/README.md).

After updating `cassandra.yaml`, restart Cassandra so audit logging takes effect:

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

- Ensure the Cassandra server has Filebeat installed before running this module
- The module creates a backup of the existing `filebeat.yml` before modification
- SSL/TLS is recommended for production environments
- Requires `gdp-middleware-helper` provider version >= 1.0.0 (with on-prem configuration resources)


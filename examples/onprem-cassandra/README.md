# On-Premises Apache Cassandra Example

This example configures Filebeat for Apache Cassandra audit logs and registers the datasource with Guardium.

## What this example does

Use this example with an existing on-premises Cassandra deployment.

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

Before using this example, enable Cassandra audit logging in `cassandra.yaml`:

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

### 1. Configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Set values such as:

```hcl
cassandra_instance_identifier = "prod-cassandra-01"
cassandra_host                = "192.168.1.100"
cassandra_audit_log_path      = "/var/log/cassandra/audit/audit.log"

enable_filebeat_setup = true
server_ip             = "192.168.1.100"
server_username       = "cassandra"
server_password       = "your-secure-password"

gdp_server        = "guardium.example.com"
gdp_port          = "8443"
gdp_username      = "admin"
gdp_password      = "your-secure-password"
gdp_client_id     = "your-client-id"
gdp_client_secret = "your-client-secret"
gdp_mu_host       = "guardium-mu-01"

logstash_port = "5044"
ssl_enable    = true
ssl_verify    = true

udc_name                   = "cassandra-prod-filebeat"
enable_universal_connector = true
```

### 2. Apply

```bash
terraform init
terraform plan
terraform apply
```

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
sudo journalctl -u filebeat -f
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

## Cleanup

```bash
terraform destroy
```

This removes the Guardium configuration and Filebeat setup managed by this example. It does not disable Cassandra audit logging.

## License

Copyright IBM Corp. 2026
SPDX-License-Identifier: Apache-2.0
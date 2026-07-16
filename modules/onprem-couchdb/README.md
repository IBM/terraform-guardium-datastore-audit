# On-Premises CouchDB Audit Module

This Terraform module automates the configuration of CouchDB audit log forwarding to Guardium Data Protection using Filebeat. This module configures Filebeat only; you must enable CouchDB audit logging separately before running Terraform.

## What this module does

This module:
1. Configures Filebeat on the CouchDB server to collect CouchDB audit logs
2. Forwards audit logs to Guardium via Logstash
3. Registers the CouchDB instance as a Universal Connector datasource in Guardium
4. Does not enable CouchDB audit logging in CouchDB itself

## Prerequisites

- CouchDB instance
- CouchDB audit logging enabled before running this module
- Filebeat installed on the CouchDB server
- SSH access to the CouchDB server
- Network connectivity from the CouchDB server to Guardium Logstash
- Guardium OAuth client credentials and Web UI credentials

## CouchDB audit logging

This module enables Filebeat log collection only. It does **not** enable CouchDB audit logging for you. Before using this module, you must enable CouchDB audit logging on the CouchDB server.

For detailed instructions on enabling CouchDB audit logging, see the [CouchDB Logging Configuration](https://docs.couchdb.org/en/stable/config/logging.html).

## Usage

```hcl
module "couchdb_audit" {
  source = "path/to/modules/onprem-couchdb"

  # CouchDB Configuration
  # Audit logging must already be enabled and writing to the configured path
  couchdb_instance_identifier = "prod-couchdb-01"
  couchdb_host                = "10.0.1.100"
  couchdb_audit_log_path      = "/var/log/couchdb/*.log"

  enable_filebeat_setup = true
  server_ip             = "10.0.1.100"
  server_username       = "couchdb"
  server_password       = var.server_password

  gdp_server        = "guardium.example.com"
  gdp_port          = "8443"
  gdp_username      = "admin"
  gdp_password      = var.gdp_password
  gdp_client_id     = "client4"
  gdp_client_secret = var.gdp_client_secret
  gdp_mu_host       = "guardium-mu-01.example.com"

  logstash_port  = "5044"
  datasource_tag = "prod-couchdb-cluster"
}
```

## Key inputs

Required:
- `couchdb_instance_identifier`
- `couchdb_host`
- `couchdb_audit_log_path`
- `datasource_tag`
- `logstash_port`
- `gdp_server`
- `gdp_username`
- `gdp_password`
- `gdp_client_id`
- `gdp_client_secret`

Common optional inputs:
- `enable_filebeat_setup` default: `true`
- `enable_universal_connector` default: `true`
- `gdp_port` default: `8443`
- `gdp_mu_host` default: empty
- `udc_name` default: auto-generated as `onprem-couchdb-<instance_identifier>`

## Outputs

- `udc_name`
- `couchdb_instance_name`
- `logstash_port`
- `audit_log_path`

## Verify

### Check CouchDB audit logs

```bash
ls -lh /var/log/couchdb/
tail -f /var/log/couchdb/*.log
```

### Check Filebeat

```bash
sudo systemctl status filebeat
sudo filebeat test config -c /etc/filebeat/filebeat.yml
```

### Check Guardium

In Guardium, verify the Universal Connector is running and receiving CouchDB audit data.

## Troubleshooting

### No logs in Guardium
- confirm CouchDB audit logging is enabled and writing logs to the configured path
- confirm Filebeat is installed and running
- confirm the audit log path is correct
- confirm the CouchDB server can reach Guardium Logstash

- Ensure the CouchDB server has Filebeat installed before running this module
- The module creates a backup of the existing `filebeat.yml` before modification
- Requires `gdp-middleware-helper` provider version >= 1.0.0 (with on-prem configuration resources)

## License

Copyright IBM Corp. 2026
SPDX-License-Identifier: Apache-2.0

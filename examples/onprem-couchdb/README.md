# On-Premises CouchDB Example

This example demonstrates how to configure on-premises CouchDB audit log forwarding with IBM Guardium Data Protection using Filebeat. This example configures Filebeat only; you must enable CouchDB audit logging separately before running Terraform.

## What this example does

This example sets up:
- Filebeat configuration on the CouchDB server to collect CouchDB audit logs
- Guardium Universal Connector to receive CouchDB audit logs via Logstash
- Automatic forwarding of audit logs from CouchDB to Guardium

## Prerequisites

1. **On-premises CouchDB Instance**: CouchDB server
2. **CouchDB Audit Logging Enabled**: Audit logging must be enabled before running this example
3. **Filebeat Installed**: Filebeat must be installed on the CouchDB server
4. **SSH Access**: SSH access to the CouchDB server
5. **Network Connectivity**: CouchDB server must be able to send logs to Guardium Logstash
6. **Guardium Credentials**: OAuth client credentials and Web UI credentials

## CouchDB audit logging

This example enables Filebeat log collection only. It does **not** enable CouchDB audit logging for you. Before using this example, you must enable CouchDB audit logging on the CouchDB server.

For detailed instructions on enabling CouchDB audit logging, see the [CouchDB Logging Configuration](https://docs.couchdb.org/en/stable/config/logging.html).

## Usage

**Note:** This example will automatically configure Filebeat on your CouchDB server. You do not need to manually configure Filebeat before running Terraform, but you must manually enable CouchDB audit logging first.

### 1. Configure

```bash
cp terraform.tfvars.example terraform.tfvars
```

Set values such as:

```hcl
couchdb_instance_identifier = "prod-couchdb-01"
couchdb_host                = "192.168.1.100"
couchdb_audit_log_path      = "/var/log/couchdb/*.log"
datasource_tag              = "prod-couchdb-cluster"

enable_filebeat_setup = true
server_ip             = "192.168.1.100"
server_username       = "couchdb"
server_password       = "your-secure-password"

gdp_server        = "guardium.example.com"
gdp_port          = "8443"
gdp_username      = "admin"
gdp_password      = "your-secure-password"
gdp_client_id     = "your-client-id"
gdp_client_secret = "your-client-secret"
gdp_mu_host       = "guardium-mu-01"

logstash_port = "5044"

udc_name                   = "couchdb-prod-filebeat"
enable_universal_connector = true
```

### 2. Apply

```bash
terraform init
terraform plan
terraform apply
```

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
sudo journalctl -u filebeat -f
```

If Filebeat fails to start:
- Check `/var/log/filebeat/filebeat` for errors
- Verify the audit log path is correct
- Ensure Filebeat has read permissions on the audit log file

### Check Guardium

- Log into Guardium UI
- Navigate to the Universal Connector section
- Verify the connector is active and receiving data
- Check audit reports for CouchDB activity


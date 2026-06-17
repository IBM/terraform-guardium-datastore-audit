# On-Premises Couchbase Module

This Terraform module configures audit logging for on-premises Couchbase databases and integrates them with IBM Guardium Data Protection using Filebeat.

## Overview

This module:
- Enables audit logging on an existing Couchbase cluster
- Configures Filebeat to collect and forward Couchbase audit logs
- Creates a Guardium Universal Connector to receive the logs via Logstash
- Supports SSL/TLS encryption for secure log transmission

## Architecture

```
Couchbase Server → Audit Logs → Filebeat → Logstash (Guardium) → Universal Connector → Guardium
```

## Prerequisites

1. **On-premises Couchbase Cluster**: A running Couchbase Server (Enterprise Edition recommended for full audit capabilities)
2. **SSH Access**: SSH access to the Couchbase server with sudo privileges
3. **Filebeat**: Filebeat must be installed on the Couchbase server
4. **Guardium Data Protection**: Version 12.2.1 or above with Logstash configured
5. **Network Connectivity**: Couchbase server must be able to send logs to Guardium Logstash port
6. **Guardium Credentials**: OAuth client credentials and Web UI credentials

## Filebeat Installation

Before running this module, ensure Filebeat is installed on your Couchbase server:

### RHEL/CentOS
```bash
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.x.x-x86_64.rpm
sudo rpm -vi filebeat-8.x.x-x86_64.rpm
```

### Ubuntu/Debian
```bash
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.x.x-amd64.deb
sudo dpkg -i filebeat-8.x.x-amd64.deb
```

## Usage

```hcl
module "couchbase_audit" {
  source = "../../modules/onprem-couchbase"

  # Couchbase Configuration
  couchbase_cluster_name    = "production-cluster"
  couchbase_host            = "192.168.1.100"
  couchbase_admin_port      = "8091"
  couchbase_admin_username  = "Administrator"
  couchbase_admin_password  = var.couchbase_admin_password
  couchbase_audit_log_path  = "/opt/couchbase/var/lib/couchbase/logs/audit.log"

  # Server Connection (for SSH)
  server_ip       = "192.168.1.100"
  server_username = "couchbase"
  server_password = var.server_password

  # Guardium Configuration
  gdp_server        = "guardium.example.com"
  gdp_port          = "8443"
  gdp_username      = "admin"
  gdp_password      = var.gdp_password
  gdp_client_id     = "client4"
  gdp_client_secret = var.gdp_client_secret
  gdp_mu_host       = "guardium-mu-01"

  # Filebeat/Logstash Configuration
  logstash_port = "5002"
  ssl_enable    = true
  ssl_verify    = true
  ssl_cert_path = "/etc/pki/tls/certs/logstash-forwarder.crt"

  # Control Flags
  enable_audit_log           = true
  enable_filebeat            = true
  enable_universal_connector = true
}
```

## What Gets Configured

This module will:

1. **Enable Couchbase Audit Logging**:
   - Configures audit settings via Couchbase REST API
   - Sets audit log rotation interval
   - Specifies audit log path

2. **Configure Filebeat**:
   - Creates Filebeat configuration to monitor Couchbase audit logs
   - Configures JSON parsing for audit log entries
   - Sets up Logstash output with optional SSL/TLS
   - Adds cluster identification fields

3. **Create Guardium Universal Connector**:
   - Registers a new Universal Connector in Guardium
   - Configures it to receive logs via Filebeat/Logstash
   - Sets up proper parsing for Couchbase audit events

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| couchbase_cluster_name | Unique identifier for the Couchbase cluster | `string` | n/a | yes |
| couchbase_host | Hostname or IP address of the Couchbase server | `string` | n/a | yes |
| couchbase_admin_port | Couchbase admin port | `string` | `"8091"` | no |
| couchbase_admin_username | Couchbase administrator username | `string` | n/a | yes |
| couchbase_admin_password | Couchbase administrator password | `string` | n/a | yes |
| couchbase_audit_log_path | Path to Couchbase audit log directory | `string` | `"/opt/couchbase/var/lib/couchbase/logs/audit.log"` | no |
| server_ip | IP address or hostname of the Couchbase server | `string` | `""` | yes (if enable_audit_log or enable_filebeat is true) |
| server_username | Username for SSH connection | `string` | `""` | yes (if enable_audit_log or enable_filebeat is true) |
| server_password | Password for SSH connection | `string` | `""` | yes (if enable_audit_log or enable_filebeat is true) |
| gdp_server | Hostname/IP address of Guardium Central Manager | `string` | n/a | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"` | no |
| gdp_username | Username of Guardium Web UI user | `string` | n/a | yes |
| gdp_password | Password of Guardium Web UI user | `string` | n/a | yes |
| gdp_client_id | Client id used when running grdapi register_oauth_client | `string` | n/a | yes |
| gdp_client_secret | Client secret from output of grdapi register_oauth_client | `string` | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units | `string` | `""` | no |
| logstash_port | Port number for Logstash on Guardium server | `string` | `"5002"` | no |
| ssl_enable | Enable SSL/TLS for Logstash connection | `bool` | `true` | no |
| ssl_verify | Enable SSL certificate verification | `bool` | `true` | no |
| ssl_cert_path | Path to SSL certificate file on the Couchbase server | `string` | `"/etc/pki/tls/certs/logstash-forwarder.crt"` | no |
| enable_audit_log | Enable Couchbase audit logging configuration | `bool` | `true` | no |
| enable_filebeat | Enable Filebeat configuration | `bool` | `true` | no |
| enable_universal_connector | Enable the universal connector module | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| udc_name | Name of the Universal Connector created |
| couchbase_cluster_name | Couchbase cluster name |
| logstash_port | Logstash port configured |
| audit_log_path | Path to Couchbase audit log file |

## Verification

After applying the configuration:

1. **Check Couchbase Audit Settings**:
   check yml file: your_yml_file_path/filebeat.yml

2. **Verify Filebeat is Running**:
   ```bash
   sudo systemctl status filebeat
   sudo tail -f /var/log/filebeat/filebeat
   ```

3. **Check Audit Logs are Being Generated**:
   ```bash
   tail -f /opt/couchbase/var/lib/couchbase/logs/audit.log
   ```

4. **Generate Test Activity**:
   ```bash
   # Create a bucket
   couchbase-cli bucket-create -c localhost:8091 \
     -u Administrator -p password \
     --bucket test-audit --bucket-type couchbase \
     --bucket-ramsize 100

   # Delete the bucket
   couchbase-cli bucket-delete -c localhost:8091 \
     -u Administrator -p password \
     --bucket test-audit
   ```

5. **Verify in Guardium**:
   - Log into Guardium UI
   - Navigate to the Universal Connector section
   - Verify the connector is active and receiving data
   - Check audit reports for Couchbase activity

## Troubleshooting

### No Logs Appearing in Guardium

1. **Check Filebeat Status**:
   ```bash
   sudo systemctl status filebeat
   sudo journalctl -u filebeat -f
   ```

2. **Verify Filebeat Configuration**:
   ```bash
   sudo filebeat test config
   sudo filebeat test output
   ```

3. **Check Network Connectivity**:
   ```bash
   telnet guardium.example.com <port>
   ```

4. **Verify Couchbase Audit is Enabled**:
   check the filebeat configuration file and ensure that the audit log path is correct and the filebeat is configured to read the audit log file.

5. **Check Audit Log Permissions**:
   ```bash
   ls -la /opt/couchbase/var/lib/couchbase/logs/audit.log
   ```

### Filebeat Connection Issues

If Filebeat cannot connect to Logstash:
- Verify firewall rules allow traffic on the Logstash port
- Check SSL certificate paths and validity
- Ensure Guardium Logstash is configured to accept Filebeat input
- Review Guardium logs for connection attempts

## Couchbase Audit Events

Couchbase audit logs capture various events including:
- Authentication attempts (success/failure)
- Bucket operations (create, delete, flush)
- Document operations (read, write, delete)
- Query execution
- Index operations
- Configuration changes
- User management activities

## Security Best Practices

1. **Use SSL/TLS**: Always enable SSL for log transmission in production
2. **Secure Credentials**: Use Terraform variables and secure storage for passwords
3. **Limit SSH Access**: Use SSH keys instead of passwords when possible
4. **Audit Log Retention**: Configure appropriate retention policies
5. **Monitor Disk Space**: Ensure adequate space for audit logs

## Cleanup

To remove the configuration:

```bash
terraform destroy
```

**Note**: This will remove the Guardium configuration and Filebeat setup but will not disable Couchbase audit logging.

## Additional Resources

- [Couchbase Auditing Documentation](https://docs.couchbase.com/server/current/manage/manage-security/manage-auditing.html)
- [Filebeat Documentation](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)
- [Guardium Data Protection Documentation](https://www.ibm.com/docs/en/guardium)
- [Couchbase REST API](https://docs.couchbase.com/server/current/rest-api/rest-intro.html)

## Support

For issues or questions:
- Review Couchbase audit documentation
- Check Filebeat logs and configuration
- Verify Guardium Universal Connector status
- Contact your Guardium administrator

## License

Copyright IBM Corp. 2026
SPDX-License-Identifier: Apache-2.0
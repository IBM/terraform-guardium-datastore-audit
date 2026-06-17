# On-Premises Couchbase Audit Example

This example demonstrates how to configure audit logging and Filebeat for an on-premises Couchbase database to forward audit logs to IBM Guardium Data Protection.

## Overview

This example will:
1. Enable Couchbase audit logging via REST API
2. Configure Filebeat to forward Couchbase audit logs to Guardium
3. Create a Universal Connector in Guardium for the Couchbase instance

## Prerequisites

### Couchbase Server
- On-premises Couchbase installation (Community or Enterprise Edition)
- Couchbase web console accessible (default port 8091)
- Administrator credentials for REST API access
- Audit logging directory accessible (default: `/opt/couchbase/var/lib/couchbase/logs`)

### Server Access
- SSH access to the Couchbase server
- Sudo privileges for Filebeat configuration
- Filebeat installed on the server (version 7.x or 8.x recommended)

### Guardium
- IBM Guardium Data Protection instance
- Universal Connector capability enabled
- OAuth client registered (use `grdapi register_oauth_client`)
- Network connectivity from Couchbase server to Guardium Managed Unit

### Network Requirements
- Couchbase server can reach Guardium Managed Unit on Logstash port (default: 5044)
- Terraform execution environment can reach Couchbase server via SSH
- Terraform execution environment can reach Guardium Central Manager API

## Usage

1. **Copy the example configuration:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars` with your values:**
   ```hcl
   # Couchbase Configuration
   couchbase_instance_identifier = "prod-couchbase-01"
   couchbase_host                = "10.0.1.50"
   couchbase_admin_username      = "Administrator"
   couchbase_admin_password      = "your-password"
   
   # Server SSH Access
   server_ip       = "10.0.1.50"
   server_username = "ubuntu"
   server_password = "your-ssh-password"
   
   # Guardium Configuration
   gdp_client_id     = "your-client-id"
   gdp_client_secret = "your-client-secret"
   gdp_server        = "guardium.example.com"
   gdp_username      = "admin"
   gdp_password      = "your-guardium-password"
   gdp_mu_host       = "guardium-mu1.example.com"
   
   # Filebeat Configuration
   logstash_port  = "5044"
   datasource_tag = "couchbase-prod"
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Review the execution plan:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

6. **Verify the setup:**
   - Check Couchbase web console: Settings > Audit
   - Verify Filebeat is running: `sudo systemctl status filebeat`
   - Check Guardium web console for the Universal Connector

## What Gets Configured

### Couchbase Audit Logging
- **Audit Logging**: Enabled via REST API
- **Log Directory**: `/opt/couchbase/var/lib/couchbase/logs` (configurable)
- **Rotation Interval**: 24 hours (86400 seconds, configurable)
- **Rotation Size**: 20 MB (configurable)
- **Data Service Events**: Enabled (excluding select bucket)
- **Query/Index Events**: Enabled (excluding /admin/stats API)

### Filebeat Configuration
- **Input Type**: `filestream` for efficient log tailing
- **Log Path**: `{audit_log_directory}/audit.log`
- **JSON Parsing**: Enabled for Couchbase JSON audit format
- **Tagging**: Adds datasource tag for Guardium identification
- **Output**: Logstash endpoint on Guardium Managed Unit
- **Service**: Enabled and started automatically

### Guardium Universal Connector
- **Profile**: Couchbase Over Filebeat
- **Connector Name**: Auto-generated or custom
- **Datasource Tag**: Matches Filebeat configuration
- **Port**: Logstash port for receiving logs

## Verification Steps

### 1. Verify Couchbase Audit Logging

Check via web console:
```
http://your-couchbase-host:8091
Navigate to: Settings > Audit
```

Or via REST API:
```bash
curl -X GET http://localhost:8091/settings/audit \
  -u Administrator:password
```

### 2. Verify Filebeat Configuration

Check Filebeat status:
```bash
sudo systemctl status filebeat
```

View Filebeat logs:
```bash
sudo journalctl -u filebeat -f
```

Test Filebeat configuration:
```bash
sudo filebeat test config -c /etc/filebeat/filebeat.yml
```

### 3. Verify Audit Logs

Check audit log file:
```bash
sudo tail -f /opt/couchbase/var/lib/couchbase/logs/audit.log
```

Generate test events:
```bash
# Create a test bucket via REST API
curl -X POST http://localhost:8091/pools/default/buckets \
  -u Administrator:password \
  -d name=test-bucket \
  -d ramQuotaMB=100
```

### 4. Verify Guardium Integration

1. Log into Guardium web console
2. Navigate to: Configure > Universal Connector
3. Find your connector (e.g., "couchbase-prod-connector")
4. Verify status is "Active"
5. Check for incoming audit events

## Customization

### Audit Log Rotation

Adjust rotation settings in `terraform.tfvars`:
```hcl
# Rotate every 12 hours
audit_log_rotate_interval = 43200

# Rotate at 50 MB
audit_log_rotate_size = 50
```

### Custom Audit Log Directory

Change the audit log directory:
```hcl
couchbase_audit_log_directory = "/custom/path/to/logs"
```

### Disable Automatic Configuration

Skip audit logging or Filebeat setup:
```hcl
enable_audit_logging  = false  # Skip audit logging configuration
enable_filebeat_setup = false  # Skip Filebeat setup
```

## Troubleshooting

### Audit Logging Not Enabled

**Problem**: Audit logging is not enabled in Couchbase

**Solution**:
1. Check Couchbase admin credentials
2. Verify REST API access: `curl http://localhost:8091/settings/audit -u admin:password`
3. Check Terraform logs for API errors
4. Manually enable via web console if needed

### Filebeat Not Running

**Problem**: Filebeat service is not running

**Solution**:
```bash
# Check service status
sudo systemctl status filebeat

# View logs
sudo journalctl -u filebeat -n 50

# Restart service
sudo systemctl restart filebeat

# Test configuration
sudo filebeat test config
```

### No Logs in Guardium

**Problem**: Audit logs not appearing in Guardium

**Solution**:
1. Verify Filebeat is sending logs:
   ```bash
   sudo tail -f /var/log/filebeat/filebeat
   ```

2. Test network connectivity:
   ```bash
   telnet guardium-mu-host 5044
   ```

3. Check Universal Connector status in Guardium

4. Verify datasource tag matches between Filebeat and UDC

### SSH Connection Failed

**Problem**: Terraform cannot connect to Couchbase server

**Solution**:
1. Verify SSH credentials
2. Test SSH connection manually:
   ```bash
   ssh username@server-ip
   ```
3. Check firewall rules
4. Verify server_ip is correct

## Outputs

After successful deployment, Terraform will output:

```
udc_name                      = "onprem-couchbase-prod-couchbase-01"
couchbase_instance_identifier = "prod-couchbase-01"
audit_logging_enabled         = true
filebeat_configured           = true
universal_connector_enabled   = true
couchbase_audit_log_directory = "/opt/couchbase/var/lib/couchbase/logs"
```

## Cleanup

To remove the configuration:

```bash
terraform destroy
```

**Note**: This will:
- Remove the Universal Connector from Guardium
- NOT disable audit logging in Couchbase (manual step required)
- NOT remove Filebeat configuration (manual cleanup required)

To manually disable audit logging:
```bash
curl -X POST http://localhost:8091/settings/audit \
  -u Administrator:password \
  -d 'auditdEnabled=false'
```

## Additional Resources

- [Couchbase Audit Documentation](https://docs.couchbase.com/server/current/manage/manage-security/manage-auditing.html)
- [Filebeat Documentation](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)
- [IBM Guardium Documentation](https://www.ibm.com/docs/en/guardium)

## License

Copyright IBM Corp. 2026  
SPDX-License-Identifier: Apache-2.0
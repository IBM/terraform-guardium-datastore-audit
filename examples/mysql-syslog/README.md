# MySQL Syslog Example

This example demonstrates how to configure on-premises MySQL audit logging on Linux with IBM Guardium Data Protection using syslog protocol.

## Overview

This example sets up:
- MySQL audit plugin installation and configuration on Linux
- Guardium Universal Connector to receive MySQL audit logs via syslog
- rsyslog configuration to forward audit logs to Guardium

## Prerequisites

1. **On-premises MySQL Instance**: A MySQL server running on Linux
2. **SSH Access**: SSH access to the MySQL server
3. **Guardium Data Protection**: Version 12.2.1 or above
4. **Network Connectivity**: MySQL server must be able to send syslog messages to Guardium
5. **Guardium Credentials**: OAuth client credentials and Web UI credentials

## Usage

**Note:** This module will automatically install and configure the MySQL audit plugin on your Linux server. You don't need to manually configure MySQL before running Terraform.

## Configuration

1. Copy the example tfvars file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your specific values:
   ```hcl
   # MySQL Instance Configuration
   mysql_instance_identifier = "prod-mysql-01"
   mysql_host                = "192.168.1.100"
   mysql_port                = "3306"

   # Guardium Configuration
   gdp_server        = "guardium.example.com"
   gdp_port          = "8443"
   gdp_username      = "admin"
   gdp_password      = "your-secure-password"
   gdp_client_id     = "your-client-id"
   gdp_client_secret = "your-client-secret"
   gdp_mu_host       = "guardium-mu-01"

   # Syslog Configuration
   syslog_protocol = "TCP"
   syslog_format   = "RFC5424"

   # Universal Connector
   udc_name                   = "mysql-prod-syslog"
   enable_universal_connector = true

   # Tags
   tags = {
     Environment = "production"
     Application = "mysql-audit"
   }
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Review the planned changes:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

## What Gets Configured

This example will:
1. Install MySQL audit plugin on your Linux server
2. Configure MySQL to enable audit logging in JSON format
3. Set up rsyslog to forward audit logs to Guardium
4. Create a Guardium Universal Connector to receive the logs
5. Enable audit filtering to capture all database activity

## Verification

After applying the configuration:

1. Check Guardium Universal Connector status:
   ```bash
   # Log into Guardium and verify the connector is active
   ```

2. Generate test activity on MySQL:
   ```sql
   -- Connect to MySQL and run some queries
   SELECT * FROM information_schema.tables LIMIT 1;
   CREATE TABLE test_audit (id INT);
   DROP TABLE test_audit;
   ```

3. Verify logs in Guardium:
   - Navigate to Guardium UI
   - Check the audit reports for your MySQL instance
   - Verify that the test queries appear in the audit logs

## Troubleshooting

### No Logs Appearing in Guardium

1. **Check MySQL syslog configuration**:
   ```sql
   SHOW VARIABLES LIKE 'audit_log%';
   ```

2. **Verify network connectivity**:
   ```bash
   # From MySQL server, test connection to Guardium
   telnet guardium.example.com 514  # For UDP
   telnet guardium.example.com 601  # For TCP
   ```

3. **Check firewall rules**:
   - Ensure syslog ports are open (514 for UDP, 601 or 6514 for TCP)
   - Verify no network ACLs are blocking traffic

4. **Review Guardium logs**:
   - Check Universal Connector logs for errors
   - Verify the connector is receiving messages

### Syslog Format Mismatch

If logs are garbled or not parsing correctly:
- Verify the `syslog_format` variable matches your MySQL configuration
- Check MySQL audit plugin documentation for supported formats

### Performance Issues

If experiencing high load:
- Consider using UDP for better performance (with acceptable message loss)
- Adjust MySQL audit settings to reduce log volume
- Filter out noisy queries or users

## Cleanup

To remove the configuration:

```bash
terraform destroy
```

**Note**: This will remove the Guardium configuration but will not affect your MySQL instance or its audit plugin configuration.

## Additional Resources

- [MySQL Audit Plugin Documentation](https://dev.mysql.com/doc/refman/8.0/en/audit-log.html)
- [Guardium Data Protection Documentation](https://www.ibm.com/docs/en/guardium)
- [Syslog Protocol RFC5424](https://tools.ietf.org/html/rfc5424)
- [Syslog Protocol RFC3164](https://tools.ietf.org/html/rfc3164)

## Support

For issues or questions:
- Check the main module [README](../../modules/mysql-syslog/README.md)
- Review Guardium documentation
- Contact your Guardium administrator
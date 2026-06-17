# On-Premises Apache Cassandra Example

This example demonstrates how to configure on-premises Apache Cassandra audit log forwarding with IBM Guardium Data Protection using Filebeat. This example configures Filebeat only; you must enable Cassandra audit logging separately before running Terraform.

## Overview

This example sets up:
- Filebeat configuration on the Cassandra server to collect Cassandra audit logs
- Guardium Universal Connector to receive Cassandra audit logs via Logstash
- Automatic forwarding of audit logs from Cassandra to Guardium
- Explicit prerequisite configuration to enable Cassandra audit logging before Terraform runs

## Prerequisites

1. **On-premises Cassandra Instance**: Apache Cassandra server
2. **Cassandra Audit Logging Enabled**: Audit logging must be enabled before running this example
3. **Filebeat Installed**: Filebeat must be installed on the Cassandra server
4. **SSH Access**: SSH access to the Cassandra server
5. **Guardium Data Protection**: Version 12.2.1 or above
6. **Network Connectivity**: Cassandra server must be able to send logs to Guardium Logstash
7. **Guardium Credentials**: OAuth client credentials and Web UI credentials

## Cassandra Audit Configuration

This example enables Filebeat log collection only. It does **not** enable Cassandra audit logging for you. Before using this example, explicitly enable Cassandra audit logging on the Cassandra server.

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

**Note:** This example will automatically configure Filebeat on your Cassandra server. You do not need to manually configure Filebeat before running Terraform, but you must manually enable Cassandra audit logging first.

## Configuration

1. Copy the example tfvars file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your specific values:
   ```hcl
   # Cassandra Instance Configuration
   # Audit logging must already be enabled in cassandra.yaml and logback.xml
   cassandra_instance_identifier = "prod-cassandra-01"
   cassandra_host                = "192.168.1.100"
   cassandra_audit_log_path      = "/var/log/cassandra/audit/audit.log"

   # Filebeat Setup
   enable_filebeat_setup = true
   server_ip             = "192.168.1.100"
   server_username       = "cassandra"
   server_password       = "your-secure-password"

   # Guardium Configuration
   gdp_server        = "guardium.example.com"
   gdp_port          = "8443"
   gdp_username      = "admin"
   gdp_password      = "your-secure-password"
   gdp_client_id     = "your-client-id"
   gdp_client_secret = "your-client-secret"
   gdp_mu_host       = "guardium-mu-01"

   # Logstash Configuration
   logstash_port = "5044"

   # SSL/TLS Configuration
   ssl_enable = true
   ssl_verify = true

   # Universal Connector
   udc_name                   = "cassandra-prod-filebeat"
   enable_universal_connector = true

   # Tags
   tags = {
     Environment = "production"
     Application = "cassandra-audit"
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
1. Assume Cassandra audit logging is already enabled on the server
2. Configure Filebeat on your Cassandra server to monitor audit logs
3. Set up Filebeat to forward logs to Guardium Logstash
4. Create a Guardium Universal Connector to receive the logs
5. Enable SSL/TLS encryption for secure log transmission (optional)

## Verification

After applying the configuration:

1. Check Filebeat status on Cassandra server:
   ```bash
   sudo systemctl status filebeat
   ```

2. Verify Filebeat is reading Cassandra audit logs:
   ```bash
   sudo tail -f /var/log/filebeat/filebeat
   ```

3. Check Guardium Universal Connector status:
   - Log into Guardium UI
   - Navigate to Universal Connector section
   - Verify the connector is active and receiving data

4. Generate test activity on Cassandra:
   ```cql
   -- Connect to Cassandra and run some queries
   USE system;
   SELECT * FROM local LIMIT 1;
   CREATE KEYSPACE test_audit WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
   DROP KEYSPACE test_audit;
   ```

5. Verify logs in Guardium:
   - Navigate to Guardium UI
   - Check the audit reports for your Cassandra instance
   - Verify that the test queries appear in the audit logs

## Troubleshooting

### No Logs Appearing in Guardium

1. **Check Cassandra audit logging**:
   ```bash
   # Verify audit log file exists and is being written to
   ls -lh /var/log/cassandra/audit/
   tail -f /var/log/cassandra/audit/audit.log
   ```

2. **Check Filebeat status**:
   ```bash
   sudo systemctl status filebeat
   sudo journalctl -u filebeat -f
   ```

3. **Verify Filebeat configuration**:
   ```bash
   sudo filebeat test config -c /etc/filebeat/filebeat.yml
   sudo filebeat test output -c /etc/filebeat/filebeat.yml
   ```

4. **Check network connectivity**:
   ```bash
   # From Cassandra server, test connection to Guardium
   telnet guardium.example.com 5044
   ```

5. **Check firewall rules**:
   - Ensure Logstash port (default 5044) is open
   - Verify no network ACLs are blocking traffic

6. **Review Guardium logs**:
   - Check Universal Connector logs for errors
   - Verify the connector is receiving messages

### Filebeat Configuration Issues

If Filebeat fails to start:
- Check `/var/log/filebeat/filebeat` for errors
- Verify the audit log path is correct
- Ensure Filebeat has read permissions on the audit log file

### SSL/TLS Issues

If experiencing SSL/TLS connection problems:
- Verify the certificate path is correct on the Cassandra server
- Check certificate validity and expiration
- Try disabling SSL verification temporarily for testing (not recommended for production)

### Performance Issues

If experiencing high load:
- Monitor Filebeat resource usage
- Adjust Cassandra audit settings to reduce log volume
- Consider filtering out noisy queries or keyspaces
- Use bulk_max_size in Filebeat configuration to batch events

## Cleanup

To remove the configuration:

```bash
terraform destroy
```

**Note**: This will remove the Guardium configuration and Filebeat setup. It will not affect your Cassandra instance or its Cassandra audit logging configuration.

## Additional Resources

- [Apache Cassandra Audit Logging Documentation](https://cassandra.apache.org/doc/latest/cassandra/operating/audit_logging.html)
- [Filebeat Documentation](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)
- [Guardium Data Protection Documentation](https://www.ibm.com/docs/en/guardium)
- [Filebeat Logstash Output](https://www.elastic.co/guide/en/beats/filebeat/current/logstash-output.html)

## Support

For issues or questions:
- Check the main module [README](../../modules/onprem-cassandra/README.md)
- Review Guardium documentation
- Contact your Guardium administrator
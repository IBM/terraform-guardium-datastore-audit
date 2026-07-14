# On-Premises Apache Cassandra Example

This example demonstrates how to configure on-premises Apache Cassandra audit log forwarding with IBM Guardium Data Protection using Filebeat. This example configures Filebeat only; you must enable Cassandra audit logging separately before running Terraform.


## What this example does

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
6. **Network Connectivity**: Cassandra server must be able to send logs to Guardium Logstash
7. **Guardium Credentials**: OAuth client credentials and Web UI credentials

## Cassandra audit logging

This example enables Filebeat log collection only. It does **not** enable Cassandra audit logging for you. Before using this example, you must enable Cassandra audit logging on the Cassandra server.

For detailed instructions on enabling Cassandra audit logging, see the [Cassandra Guardium documentation](https://github.com/IBM/universal-connectors/blob/main/filter-plugin/logstash-filter-cassandra-guardium/README.md).

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

If Filebeat fails to start:
- Check `/var/log/filebeat/filebeat` for errors
- Verify the audit log path is correct
- Ensure Filebeat has read permissions on the audit log file

# AWS Aurora PostgreSQL Session-Level Audit Configuration

This module configures session-level auditing for Aurora PostgreSQL clusters using the pgAudit extension. It enables comprehensive logging of SQL statements executed against your database, providing a detailed audit trail for security and compliance purposes.

## Overview

Session-level auditing in Aurora PostgreSQL logs all SQL statements of specified types. This module:

1. Configures the pgAudit extension in your Aurora PostgreSQL cluster
2. Sets up appropriate parameter groups with session audit settings
3. Configures either SQS or CloudWatch for log collection
4. Integrates with Guardium Data Protection for log analysis and security monitoring

## How It Works

The module uses PostgreSQL's pgAudit extension with session-level auditing mode. In this mode:

- All SQL statements of specified types are logged (SELECT, INSERT, UPDATE, etc.)
- By default, it logs all statement types except miscellaneous commands
- Logs are sent to either SQS or CloudWatch
- Guardium Universal Connector processes these logs

This approach provides comprehensive coverage of database activities, suitable for environments with strict audit requirements.

## Usage

```hcl
module "aurora_postgresql_session_audit" {
  source = "github.com/IBM/terraform-guardium-datastore-audit//modules/aws-aurora-postgres-session"

  # AWS configuration
  aws_region = "us-east-1"
  aurora_postgres_cluster_identifier = "my-aurora-cluster"
  
  # Guardium configuration
  udc_aws_credential = "aws-credential-name"
  gdp_client_secret = "client-secret"
  gdp_client_id = "client-id"
  gdp_server = "guardium.example.com"
  gdp_username = "guardium-user"
  gdp_password = "guardium-password"
  gdp_ssh_username = "guardium-ssh-user"
  gdp_ssh_privatekeypath = "/path/to/private/key"
  gdp_mu_host = "mu.guardium.example.com"
  
  # Log export configuration
  log_export_type = "SQS"  # or "Cloudwatch"
}
```

## Required Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| aurora_postgres_cluster_identifier | Aurora PostgreSQL cluster identifier to be monitored | string | - |
| udc_aws_credential | Name of AWS credential defined in Guardium | string | - |
| gdp_client_secret | Client secret from output of grdapi register_oauth_client | string | - |
| gdp_client_id | Client id used when running grdapi register_oauth_client | string | - |
| gdp_server | Hostname/IP address of Guardium Central Manager | string | - |
| gdp_username | Username of Guardium Web UI user | string | - |
| gdp_password | Password of Guardium Web UI user | string | - |
| gdp_ssh_username | Guardium OS user with SSH access | string | - |
| gdp_ssh_privatekeypath | Private SSH key to connect to Guardium OS with ssh username | string | - |

## Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| aws_region | AWS region where the Aurora cluster is located | string | "us-east-1" |
| force_failover | Whether to force failover during parameter group update | bool | false |
| udc_name | Name for universal connector | string | "aurora-postgres-session" |
| gdp_port | Port of Guardium Central Manager | string | "8443" |
| gdp_mu_host | Comma separated list of Guardium Managed Units to deploy profile | string | "" |
| enable_universal_connector | Whether to enable the universal connector module | bool | true |
| csv_start_position | Start position for UDC | string | "end" |
| csv_interval | Polling interval for UDC | string | "5" |
| csv_event_filter | UDC Event filters | string | "" |
| log_export_type | The type of log exporting to be configured: "SQS" or "Cloudwatch" | string | "SQS" |
| pg_audit_log | PGAudit log configuration | string | "all, -misc" |
| codec_pattern | Codec pattern for Aurora PostgreSQL CloudWatch logs | string | "plain" |
| cloudwatch_endpoint | Custom endpoint URL for AWS CloudWatch. Leave empty to use default AWS endpoint | string | "" |
| use_aws_bundled_ca | Whether to use the AWS bundled CA certificates for CloudWatch connection | bool | true |
| use_multipart_upload | Use multipart/form-data upload instead of SFTP (recommended) | bool | true |

## Session Audit Configuration

By default, the module configures pgAudit to log all statement types except miscellaneous commands:

```
pgaudit.log = "all, -misc"
```

You can customize this by setting the `pg_audit_log` variable. Available statement types include:

- READ: SELECT, COPY WHEN FROM
- WRITE: INSERT, UPDATE, DELETE, TRUNCATE, COPY WHEN TO
- FUNCTION: Function calls and DO blocks
- ROLE: GRANT, REVOKE, CREATE/ALTER/DROP ROLE
- DDL: All DDL statements
- MISC: DISCARD, FETCH, CHECKPOINT, VACUUM, SET
- ALL: All statement types

For example, to log only write operations:
```hcl
pg_audit_log = "write"
```

To log multiple types:
```hcl
pg_audit_log = "write, ddl, role"
```

To exclude specific types:
```hcl
pg_audit_log = "all, -misc, -read"
```

## CSV Profile Upload Methods

The module supports two methods for uploading the Universal Connector CSV profile to Guardium:

### Multipart Upload (Recommended - Default)
When `use_multipart_upload = true` (default):
- CSV file is created in your local workspace (`.terraform/` directory)
- Provider uploads file content directly via HTTP multipart/form-data
- No SFTP configuration required
- More secure and easier to use
- Works seamlessly when using modules from remote sources (Git/Terraform Registry)

### Legacy SFTP Method
When `use_multipart_upload = false`:
- CSV file is uploaded to Guardium via SFTP first
- Provider then sends the server path to Guardium API
- Requires SFTP access to Guardium server
- Maintains backward compatibility with existing deployments

**Recommendation**: Use the default multipart upload method unless you have specific requirements for SFTP.

## Log Export Options

The module supports two methods for exporting logs:

### CloudWatch
- Direct integration with CloudWatch Logs
- Simpler setup but may have higher costs for large log volumes
- Configure with `log_export_type = "Cloudwatch"`

### SQS
- Uses a Lambda function to export logs to SQS
- More complex but can be more cost-effective for large volumes
- Configure with `log_export_type = "SQS"`

## Dependencies

This module depends on:
- AWS Aurora PostgreSQL cluster with pgAudit extension available
- Guardium Data Protection platform
- AWS credentials configured in Guardium
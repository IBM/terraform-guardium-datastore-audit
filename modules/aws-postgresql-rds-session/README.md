# AWS PostgreSQL RDS Session-Level Audit Configuration

This module configures session-level auditing for PostgreSQL RDS instances using the pgAudit extension. It enables comprehensive monitoring of all database activity by capturing SQL statements at the session level.

## Overview

Session-level auditing in PostgreSQL provides broad coverage of database activity. This module:

1. Configures pgAudit to log all SQL statements (except miscellaneous commands)
2. Sets up either SQS or CloudWatch for log collection
3. Configures Guardium Universal Connector to process these logs

## Guardium Data Protection Version Compatibility

**Important:** The upload method for Universal Connector profiles depends on your Guardium Data Protection (GDP) version:

- **GDP 12.2.1 and above**: Use API-based upload by setting `use_multipart_upload = true` (default and recommended)
- **GDP versions below 12.2.1**: Use SFTP-based upload by setting `use_multipart_upload = false`

When using SFTP (`use_multipart_upload = false`), you must also provide `gdp_ssh_username` and `gdp_ssh_privatekeypath` for authentication.

## How It Works

The module uses PostgreSQL's pgAudit extension with session-level auditing mode. In this mode:

- pgAudit is configured to log all SQL statements (except miscellaneous commands)
- All database activity is captured regardless of which user or role performs it
- Logs are sent to either SQS or CloudWatch
- Guardium Universal Connector processes these logs

This approach provides comprehensive coverage of database activity, ensuring that all relevant operations are captured for security and compliance purposes.

## Usage

**For GDP 12.2.1 and above (API upload - recommended):**
```hcl
module "datastore-audit_aws-postgresql-rds-session" {
  source = "IBM/datastore-audit/guardium//modules/aws-postgresql-rds-session"

  # AWS configuration
  aws_region = "us-east-1"
  postgres_rds_cluster_identifier = "my-postgres-db"
  
  # Guardium configuration
  udc_aws_credential = "aws-credential-name"
  gdp_client_secret = "client-secret"
  gdp_client_id = "client-id"
  gdp_server = "guardium.example.com"
  gdp_username = "guardium-user"
  gdp_password = "guardium-password"
  
  # Log export configuration
  log_export_type = "Cloudwatch"  # or "SQS"
  
  # API upload (default for GDP 12.2.1+)
  use_multipart_upload = true
}
```

**For GDP versions below 12.2.1 (SFTP upload):**
```hcl
module "datastore-audit_aws-postgresql-rds-session" {
  source = "IBM/datastore-audit/guardium//modules/aws-postgresql-rds-session"

  # AWS configuration
  aws_region = "us-east-1"
  postgres_rds_cluster_identifier = "my-postgres-db"
  
  # Guardium configuration
  udc_aws_credential = "aws-credential-name"
  gdp_client_secret = "client-secret"
  gdp_client_id = "client-id"
  gdp_server = "guardium.example.com"
  gdp_username = "guardium-user"
  gdp_password = "guardium-password"
  gdp_ssh_username = "guardium-ssh-user"
  gdp_ssh_privatekeypath = "/path/to/private/key"
  
  # Log export configuration
  log_export_type = "Cloudwatch"  # or "SQS"
  
  # SFTP upload for GDP < 12.2.1
  use_multipart_upload = false
}
```

## Required Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| udc_aws_credential | Name of AWS credential defined in Guardium | string | - |
| gdp_client_secret | Client secret from output of grdapi register_oauth_client | string | - |
| gdp_client_id | Client id used when running grdapi register_oauth_client | string | - |
| gdp_server | Hostname/IP address of Guardium Central Manager | string | - |
| gdp_username | Username of Guardium Web UI user | string | - |
| gdp_password | Password of Guardium Web UI user | string | - |
| gdp_ssh_username | Guardium OS user with SSH access (required when use_multipart_upload = false) | string | - |
| gdp_ssh_privatekeypath | Private SSH key to connect to Guardium OS (required when use_multipart_upload = false) | string | - |

## Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| aws_region | AWS region where the RDS instance is located | string | "us-east-1" |
| postgres_rds_cluster_identifier | RDS PostgreSQL cluster identifier | string | "guardium-postgres" |
| force_failover | Whether to force failover during parameter group update | bool | true |
| udc_name | Name for universal connector | string | "rds-postgres-session" |
| gdp_port | Port of Guardium Central Manager | string | "8443" |
| gdp_mu_host | Comma separated list of Guardium Managed Units to deploy profile | string | "" |
| enable_universal_connector | Whether to enable the universal connector module | bool | true |
| csv_start_position | Start position for UDC | string | "end" |
| csv_interval | Polling interval for UDC | string | "5" |
| csv_event_filter | UDC Event filters | string | "" |
| codec_pattern | Codec pattern for RDS PostgreSQL CloudWatch logs | string | "plain" |
| cloudwatch_endpoint | Custom endpoint URL for AWS CloudWatch. Leave empty to use default AWS endpoint | string | "" |
| use_aws_bundled_ca | Whether to use the AWS bundled CA certificates for CloudWatch connection | bool | true |
| use_multipart_upload | Use API upload (true, for GDP 12.2.1+) or SFTP (false, for GDP < 12.2.1) | bool | true |
| profile_upload_directory | Directory path for SFTP upload (chroot path for CLI user) | string | "/upload" |
| profile_api_directory | Full filesystem path for Guardium API to read CSV files | string | "/var/IBM/Guardium/file-server/upload" |
| log_export_type | The type of log exporting to be configured: "SQS" or "Cloudwatch" | string | "object" |

## Audit Log Configuration

This module configures pgAudit to log the following statement classes:

- READ: SELECT, COPY when the source is a relation or a query
- WRITE: INSERT, UPDATE, DELETE, TRUNCATE, COPY when the destination is a relation
- FUNCTION: Function calls and DO blocks
- ROLE: GRANT, REVOKE, CREATE/ALTER/DROP ROLE
- DDL: All DDL that is not included in the ROLE class
- MISC: Miscellaneous commands, such as DISCARD, FETCH, CHECKPOINT, VACUUM, SET (excluded by default)

The default configuration logs all statement classes except MISC to reduce noise in the audit logs.

## Dependencies

This module depends on:
- AWS RDS PostgreSQL instance with pgAudit extension enabled
- Guardium Data Protection platform
- AWS credentials configured in Guardium

## Comparison with Object-Level Auditing

Session-level auditing differs from object-level auditing in the following ways:

1. **Coverage**: Session-level auditing captures all SQL statements regardless of which tables they affect, while object-level auditing focuses only on specific tables.

2. **Configuration**: Session-level auditing is simpler to configure as it doesn't require setting up specific grants for tables.

3. **Log Volume**: Session-level auditing typically generates more logs since it captures all database activity.

4. **Use Case**: Session-level auditing is ideal for comprehensive security monitoring and compliance requirements, while object-level auditing is better for focused monitoring of sensitive tables.

Choose session-level auditing when you need comprehensive coverage of all database activity, and object-level auditing when you want to focus on specific tables or operations.

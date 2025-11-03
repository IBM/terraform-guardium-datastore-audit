# AWS Aurora PostgreSQL Object-Level Audit Configuration

This module configures object-level auditing for Aurora PostgreSQL clusters using the pgAudit extension. It allows you to monitor specific tables and operations by creating a dedicated audit role and granting it permissions on selected tables.

## Overview

Object-level auditing in Aurora PostgreSQL provides granular control over what database operations are audited. This module:

1. Creates a dedicated audit role (`aurora_pgaudit`)
2. Grants specific permissions to this role for the tables you want to monitor
3. Configures pgAudit to log operations performed by this role
4. Sets up either SQS or CloudWatch for log collection
5. Configures Guardium Universal Connector to process these logs

## How It Works

The module uses PostgreSQL's pgAudit extension with object-level auditing mode. In this mode:

- A dedicated role (`aurora_pgaudit`) is created using the PostgreSQL provider
- This role is granted specific permissions on tables you want to monitor
- When these permissions are used, pgAudit logs the operations
- Logs are sent to either SQS or CloudWatch
- Guardium Universal Connector processes these logs

This approach allows you to focus auditing on specific tables and operations, reducing the volume of audit logs while still capturing critical activity.

## Usage

```hcl
module "aurora_postgresql_object_audit" {
  source = "github.com/IBM/terraform-guardium-datastore-audit//modules/aws-aurora-postgres-object"

  # AWS configuration
  aws_region = "us-east-1"
  aurora_postgres_cluster_identifier = "my-aurora-cluster"
  
  # Database connection details
  db_host = "my-aurora-cluster.cluster-endpoint.region.rds.amazonaws.com"
  db_port = 5432
  db_username = "admin"
  db_password = "password"
  db_name = "postgres"
  
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
  
  # Tables to monitor
  tables = [
    {
      schema = "public"
      table = "users"
      grants = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    },
    {
      schema = "public"
      table = "orders"
      grants = ["SELECT", "INSERT"]
    }
  ]
}
```

## Required Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| db_host | The hostname of the Aurora PostgreSQL cluster endpoint | string | - |
| db_username | The master username for the Aurora PostgreSQL cluster | string | - |
| db_password | The master password for the Aurora PostgreSQL cluster | string | - |
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
| aurora_postgres_cluster_identifier | Aurora PostgreSQL cluster identifier | string | "guardium-aurora-postgres" |
| force_failover | Whether to force failover during parameter group update | bool | false |
| db_port | The port of the Aurora PostgreSQL cluster | number | 5432 |
| db_name | The database to connect to | string | "postgres" |
| udc_name | Name for universal connector | string | "aurora-postgres-object" |
| gdp_port | Port of Guardium Central Manager | string | "8443" |
| gdp_mu_host | Comma separated list of Guardium Managed Units to deploy profile | string | "" |
| enable_universal_connector | Whether to enable the universal connector module | bool | true |
| csv_start_position | Start position for UDC | string | "end" |
| csv_interval | Polling interval for UDC | string | "5" |
| csv_event_filter | UDC Event filters | string | "" |
| log_export_type | The type of log exporting to be configured: "SQS" or "Cloudwatch" | string | "SQS" |
| tables | List of tables to monitor | list(object) | [] |

## Table Configuration

The `tables` variable allows you to specify which tables to monitor and what operations to audit:

```hcl
tables = [
  {
    schema = "public"    # Schema name
    table  = "users"     # Table name
    grants = ["SELECT", "INSERT", "UPDATE", "DELETE"]  # Operations to audit
  }
]
```

Valid grant options are:
- SELECT
- INSERT
- UPDATE
- DELETE
- REFERENCES
- TRIGGER
- ALL

## Dependencies

This module depends on:
- AWS Aurora PostgreSQL cluster with pgAudit extension enabled
- Guardium Data Protection platform
- AWS credentials configured in Guardium
- PostgreSQL provider for Terraform
- gdp-middleware-helper provider for role checking
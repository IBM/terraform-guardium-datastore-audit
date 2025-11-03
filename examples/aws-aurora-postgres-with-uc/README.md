# AWS Aurora PostgreSQL with Universal Connector

This example demonstrates how to configure AWS Aurora PostgreSQL with Guardium Universal Connector using either object-level or session-level auditing.

## Overview

This module provides a flexible approach to auditing Aurora PostgreSQL databases on AWS by allowing you to choose between two auditing methods:

1. **Object-level auditing** - Monitors specific tables and operations based on configured grants
2. **Session-level auditing** - Monitors all database activity at the session level

## Usage

```hcl
module "aurora_postgresql_audit" {
  source = "github.com/IBM/terraform-guardium-datastore-audit//examples/aws-aurora-postgres-with-uc"

  # Choose audit type: "object" or "session"
  audit_type = "object"
  
  # AWS configuration
  aws_region = "us-east-1"
  aurora_postgres_cluster_identifier = "my-aurora-postgres-db"
  
  # Database connection details
  db_host = "my-aurora-postgres-db.cluster-example.region.rds.amazonaws.com"
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
  
  # For object-level auditing, specify tables to monitor
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

## Prerequisites

Before applying this configuration, you need to:

1. Have an existing Aurora PostgreSQL cluster with pgAudit extension enabled
2. Have Guardium Data Protection platform set up
3. Have AWS credentials configured in Guardium

## Important: Parameter Group Import

When applying this configuration, you need to import the existing parameter group:

```
terraform import module.aurora_postgresql_audit_config.module.aurora-postgres-parameter-group.aws_rds_cluster_parameter_group.guardium aurora-postgresql-[your-identifier]-guardium-postgresql-params
```

To get the parameter group name, you can use the AWS CLI:
```
aws rds describe-db-cluster-parameter-groups --query "DBClusterParameterGroups[*].DBClusterParameterGroupName" --output text
```

Look for a parameter group with a name pattern like `aurora-postgresql-[your-identifier]-guardium-postgresql-params`.

## Audit Types

### Object-Level Auditing

When `audit_type = "object"`, the module configures PostgreSQL's pgAudit extension to monitor specific tables and operations. This approach:

- Creates a dedicated audit role (`rds_pgaudit`)
- Grants specific permissions to this role for the tables you want to monitor
- Configures pgAudit to log operations performed by this role

This approach is more targeted and can reduce the volume of audit logs by focusing only on specific tables and operations.

### Session-Level Auditing

When `audit_type = "session"`, the module configures PostgreSQL's pgAudit extension to monitor all database activity at the session level. This approach:

- Configures pgAudit to log all SQL statements (except miscellaneous commands)
- Provides comprehensive coverage of database activity

This approach is simpler to set up and ensures all database activity is captured, but may generate a larger volume of audit logs.

## Required Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| audit_type | The type of audit to use: "object" or "session" | string | "object" |
| aws_region | AWS region where the Aurora PostgreSQL cluster is located | string | "us-east-1" |
| db_host | The hostname of the Aurora PostgreSQL cluster | string | - |
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
| aurora_postgres_cluster_identifier | Aurora PostgreSQL cluster identifier | string | "guardium-aurora-postgres" |
| force_failover | Whether to force failover during parameter group update | bool | true |
| db_port | The port of the Aurora PostgreSQL cluster | number | 5432 |
| db_name | The database to connect to | string | "postgres" |
| gdp_port | Port of Guardium Central Manager | string | "8443" |
| gdp_mu_host | Comma separated list of Guardium Managed Units to deploy profile | string | "" |
| enable_universal_connector | Whether to enable the universal connector module | bool | true |
| csv_start_position | Start position for UDC | string | "end" |
| csv_interval | Polling interval for UDC | string | "5" |
| csv_event_filter | UDC Event filters | string | "" |
| log_export_type | The type of log exporting to be configured: "SQS" or "Cloudwatch" | string | "object" |
| tables | List of tables to monitor (for object-level auditing) | list(object) | [] |
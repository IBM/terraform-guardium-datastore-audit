# AWS Aurora PostgreSQL with Object-Level Auditing (Kafka-based UC)

This example demonstrates how to configure AWS Aurora PostgreSQL with Guardium Universal Connector using object-level auditing and a Kafka-based Universal Connector.

## Architecture

```text
┌──────────────────────┐     ┌──────────────────────┐     ┌──────────────────────┐
│                      │     │                      │     │                      │
│  Aurora PostgreSQL   │────►│  CloudWatch Logs     │────►│  Guardium Kafka-     │
│  Cluster             │     │  (pgAudit Logs)      │     │  based UC            │
│                      │     │                      │     │                      │
└──────────────────────┘     └──────────────────────┘     └──────────────────────┘
                                                                   │
                                                                   ▼
                                                          ┌──────────────────────┐
                                                          │                      │
                                                          │  Guardium Data       │
                                                          │  Protection          │
                                                          │                      │
                                                          └──────────────────────┘
```

## Data Flow

1. Object-level auditing is enabled on the Aurora PostgreSQL cluster via pgAudit.
2. Audit logs are published to CloudWatch Logs.
3. Guardium Kafka-based Universal Connector reads the CloudWatch audit log stream.
4. Guardium processes and analyzes the Aurora PostgreSQL audit activity.

## Overview

Object-level auditing in Aurora PostgreSQL provides granular control over what database operations are audited. This example:

1. Creates a dedicated audit role (`rds_pgaudit`)
2. Grants specific permissions to this role for the tables you want to monitor
3. Configures pgAudit to log operations performed by this role
4. Sets up CloudWatch for log collection
5. Configures a Kafka-based Guardium Universal Connector to process these logs by setting `uc_mode = "kafka"` in the module

## How It Works

The example uses PostgreSQL's pgAudit extension with object-level auditing mode. In this mode:

- A dedicated role (`rds_pgaudit`) is created
- This role is granted specific permissions on tables you want to monitor
- When these permissions are used, pgAudit logs the operations
- Logs are sent to CloudWatch
- Guardium Kafka-based Universal Connector processes these logs

This approach allows you to focus auditing on specific tables and operations, reducing the volume of audit logs while still capturing critical activity.

## Prerequisites

Before using this example, ensure you have:

1. **AWS Resources**:
   - An existing Aurora PostgreSQL cluster with pgAudit extension available
   - AWS credentials configured for Terraform

2. **Guardium Data Protection**:
   - A running Guardium Data Protection instance (version 12.2.1 or above)
   - Completed the one-time manual configurations as described in [Preparing Guardium Documentation](https://github.com/IBM/terraform-guardium-gdp/blob/main/docs/preparing-guardium.md):
      - OAuth client registered via `grdapi register_oauth_client`
      - AWS credentials configured in Guardium Data Protection
   - A Kafka cluster configured in Guardium
   - One or more Guardium Managed Units available for UC deployment

## Usage

### 1. Create a terraform.tfvars File

Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values to match your environment:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Fill in all required values before continuing:
- `aurora_postgres_cluster_identifier` - the name of your Aurora cluster (must not be empty)
- `db_host`, `db_username`, `db_password` - database connection details
- The Guardium connection details
- `kafka_cluster_name` - must match a Kafka cluster already configured in Guardium

To find your cluster identifier:
```bash
aws rds describe-db-clusters --query "DBClusters[*].DBClusterIdentifier" --output text
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Apply the Configuration

Run `terraform apply` to create the resources. Any existing custom parameter group will be detected and imported automatically via [`imports.tf`](./imports.tf):

```bash
terraform apply
```

Review the planned changes and type `yes` to apply them.

**Please note:** By default, this example uses `skip_reboot = true`. After apply, manually reboot the database to activate audit logging. Set `skip_reboot = false` if you want Terraform to perform the reboot.

### 4. Verify the Configuration

After successful application:

1. Log in to Guardium Data Protection.
2. Navigate to **Universal Connector** → **Datasource Profile Management**.
3. Verify that the Kafka-based Aurora PostgreSQL datasource profile has been created.
4. Confirm the profile is deployed to the expected managed units.

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

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region where the Aurora cluster is deployed | `string` | n/a | yes |
| aurora_postgres_cluster_identifier | Aurora PostgreSQL cluster identifier to be monitored | `string` | n/a | yes |
| force_failover | Force failover when applying parameter changes (requires Multi-AZ) | `bool` | `true` | no |
| skip_reboot | Skip automatic reboot after parameter changes | `bool` | `true` | no |
| db_host | The hostname of the Aurora PostgreSQL cluster endpoint | `string` | n/a | yes |
| db_port | The port of the Aurora PostgreSQL cluster | `number` | `5432` | no |
| db_username | The master username for the Aurora PostgreSQL cluster | `string` | n/a | yes |
| db_password | The master password for the Aurora PostgreSQL cluster | `string` | n/a | yes |
| db_name | The database to connect to | `string` | `"postgres"` | no |
| ssl_mode | SSL mode for PostgreSQL connection | `string` | `"require"` | no |
| udc_name | Name for universal connector | `string` | `"aurora-postgres-gdp-object-kafka"` | no |
| udc_aws_credential | Name of AWS credential defined in Guardium | `string` | n/a | yes |
| gdp_server | Hostname/IP address of Guardium Central Manager | `string` | n/a | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"` | no |
| gdp_username | Username of Guardium Web UI user | `string` | n/a | yes |
| gdp_password | Password of Guardium Web UI user | `string` | n/a | yes |
| gdp_client_id | Guardium OAuth client ID | `string` | n/a | yes |
| gdp_client_secret | Guardium OAuth client secret | `string` | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units to deploy profile | `string` | `""` | no |
| enable_audit_setup | Whether to configure pgAudit on the cluster (parameter group, role, and table grants). Set to false to only manage the Universal Connector | `bool` | `true` | no |
| enable_universal_connector | Whether to enable the universal connector module | `bool` | `true` | no |
| tables | List of tables to monitor with object-level auditing | `list(object)` | `[]` | no |
| kafka_cluster_name | Kafka cluster name configured in Guardium | `string` | `"kafka"` | no |
| use_elb | Whether to use ELB for Kafka-based UC | `bool` | `false` | no |
| event_delay | Event delay in minutes for Kafka-based UC | `number` | `15` | no |
| nodata_threshold_min | No data threshold in minutes for Kafka-based UC | `number` | `60` | no |
| unmask | Whether to unmask sensitive data in audit logs | `bool` | `false` | no |
| filter_pattern | CloudWatch Logs filter pattern for filtering audit logs | `string` | `"None"` | no |
| poll_interval | Poll interval in minutes for Kafka-based UC | `number` | `1` | no |
| event_limit | Maximum number of events to retrieve per poll for Kafka-based UC | `number` | `1000` | no |
| start_time | Start time as epoch in milliseconds for Kafka-based UC (0 = disabled) | `number` | `0` | no |
| tags | Map of tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| reboot_required | Whether manual reboot is required to enable audit logging |

## Dependencies

This example depends on:
- AWS Aurora PostgreSQL cluster with pgAudit extension enabled
- Guardium Data Protection platform with a configured Kafka cluster
- AWS credentials configured in Guardium

## When to Use Object-Level Auditing

Object-level auditing is ideal when:

- You need to focus on specific tables (e.g., those containing sensitive data)
- You want to reduce the volume of audit logs
- You need granular control over which operations are audited
- You have specific compliance requirements for certain tables

## Kafka vs CloudWatch/SQS UC

This example uses a Kafka-based Universal Connector (`uc_mode = "kafka"`) instead of the default CloudWatch or SQS polling connectors. Use this variant when:

- You already have a Kafka cluster configured in your Guardium environment
- You prefer Kafka-based event streaming over polling-based log collection
- You require the Kafka connector's configurable event delay and filtering options

For the standard polling-based approach, see the [aws-aurora-postgres-object](../aws-aurora-postgres-object) example.

## Troubleshooting

### Parameter Group Issues

If you encounter errors related to parameter groups:
- Ensure `terraform.tfvars` is configured with the correct `aurora_postgres_cluster_identifier`
- Ensure your AWS credentials have permissions to read and modify RDS cluster parameter groups
- Check that the parameter group is associated with your Aurora cluster

### Connection Issues

If Terraform cannot connect to the database:
- Verify the `db_host` is the cluster endpoint (not a reader endpoint)
- Check security group rules allow connections from your Terraform execution environment
- Ensure the database credentials are correct
- Verify SSL mode settings match your Aurora cluster configuration

### Kafka UC Issues

If the Kafka-based UC is not receiving events:
- Confirm `kafka_cluster_name` matches the cluster name configured in Guardium
- Verify the Kafka cluster is running and reachable from the Guardium Managed Units
- Check `event_delay` and `poll_interval` are appropriate for your environment

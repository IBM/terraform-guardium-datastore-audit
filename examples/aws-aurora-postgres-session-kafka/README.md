# AWS Aurora PostgreSQL with Session-Level Auditing (Kafka-based UC)

This example demonstrates how to configure AWS Aurora PostgreSQL with Guardium Universal Connector using session-level auditing and a Kafka-based Universal Connector.

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

1. Session-level pgAudit logging is enabled on the Aurora PostgreSQL cluster via a cluster parameter group.
2. Audit logs are published to CloudWatch Logs.
3. Guardium Kafka-based Universal Connector reads the CloudWatch audit log stream.
4. Guardium processes and analyzes the Aurora PostgreSQL audit activity.

## Overview

Session-level auditing logs all statements of the classes configured in `pg_audit_log` for every session. This example:

1. Configures the Aurora cluster parameter group with pgAudit session logging (`pg_audit_log`)
2. Enables CloudWatch log export for the cluster
3. Configures a Kafka-based Guardium Universal Connector by setting `uc_mode = "kafka"` in the module

## Prerequisites

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

```bash
cp terraform.tfvars.example terraform.tfvars
```

Fill in all required values before continuing:
- `aurora_postgres_cluster_identifier` - the name of your Aurora cluster (must not be empty)
- The Guardium connection details
- `kafka_cluster_name` - must match a Kafka cluster already configured in Guardium

Optional settings:
- `udc_name` - overrides the Universal Connector profile name. If unset or empty, it defaults to `{aws_region}-{aurora_postgres_cluster_identifier}-{aws_account_id}`
- `timestamp_start` - initial polling time in UTC ISO 8601 with milliseconds (for example `2026-10-19T21:17:05.000Z`). If empty, the current time (UTC) is used. It is recorded at the first apply and does not change on later applies; set the variable to choose a different start time
- `poll_interval_sec` and `poll_interval` - polling interval, in seconds and minutes. The defaults are 30 seconds and 0 minutes, and the two values are added together

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

**Please note:** By default, this example uses `skip_reboot = true`. After apply, manually reboot the database to activate audit logging. Set `skip_reboot = false` if you want Terraform to perform the reboot.

### 4. Verify the Configuration

1. Log in to Guardium Data Protection.
2. Navigate to **Universal Connector** → **Datasource Profile Management**.
3. Verify that the Kafka-based Aurora PostgreSQL datasource profile has been created.
4. Confirm the profile is deployed to the expected managed units.

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region where the Aurora cluster is deployed | `string` | n/a | yes |
| aurora_postgres_cluster_identifier | Aurora PostgreSQL cluster identifier to be monitored | `string` | n/a | yes |
| force_failover | Force failover when applying parameter changes (requires Multi-AZ) | `bool` | `true` | no |
| skip_reboot | Skip automatic reboot after parameter changes | `bool` | `true` | no |
| pg_audit_log | PGAudit log configuration for session auditing | `string` | `"all, -misc"` | no |
| udc_name | Override name for the universal connector profile. Defaults to `{aws_region}-{aurora_postgres_cluster_identifier}-{aws_account_id}` | `string` | `""` | no |
| udc_aws_credential | Name of AWS credential defined in Guardium | `string` | n/a | yes |
| gdp_server | Hostname/IP address of Guardium Central Manager | `string` | n/a | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"` | no |
| gdp_username | Username of Guardium Web UI user | `string` | n/a | yes |
| gdp_password | Password of Guardium Web UI user | `string` | n/a | yes |
| gdp_client_id | Guardium OAuth client ID | `string` | n/a | yes |
| gdp_client_secret | Guardium OAuth client secret | `string` | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units to deploy profile | `string` | `""` | no |
| enable_audit_setup | Whether to configure pgAudit on the cluster (parameter group). Set to false to only manage the Universal Connector | `bool` | `true` | no |
| enable_universal_connector | Whether to enable the universal connector module | `bool` | `true` | no |
| kafka_cluster_name | Kafka cluster name configured in Guardium | `string` | `"kafka"` | no |
| use_elb | Whether to use ELB for Kafka-based UC | `bool` | `false` | no |
| event_delay | Event delay in minutes for Kafka-based UC | `number` | `15` | no |
| nodata_threshold_min | No data threshold in minutes for Kafka-based UC | `number` | `60` | no |
| unmask | Whether to unmask sensitive data in audit logs | `bool` | `false` | no |
| filter_pattern | CloudWatch Logs filter pattern for filtering audit logs | `string` | `"None"` | no |
| poll_interval_sec | Poll interval seconds component (0-59), added to `poll_interval` | `number` | `30` | no |
| poll_interval | Poll interval in minutes for Kafka-based UC | `number` | `0` | no |
| event_limit | Maximum number of events to retrieve per poll for Kafka-based UC | `number` | `1000` | no |
| timestamp_start | Initial polling time for Kafka-based UC, UTC ISO 8601 with milliseconds (e.g. `2026-10-19T21:17:05.000Z`). Empty = use the current time (UTC), recorded at first apply | `string` | `""` | no |
| tags | Map of tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| reboot_required | Whether manual reboot is required to enable audit logging |

## Kafka vs CloudWatch/SQS UC

This example uses a Kafka-based Universal Connector (`uc_mode = "kafka"`) instead of the default CloudWatch or SQS polling connectors. Use this variant when:

- You already have a Kafka cluster configured in your Guardium environment
- You prefer Kafka-based event streaming over polling-based log collection
- You require the Kafka connector's configurable event delay and filtering options

For the standard polling-based approach, see the [aws-aurora-postgres-session](../aws-aurora-postgres-session) example.

## Troubleshooting

### Parameter Group Import Issues

- Verify the parameter group name is correct
- Ensure you have the necessary AWS permissions
- Ensure `terraform.tfvars` is configured before running `terraform plan` or `terraform apply`

### Kafka UC Issues

If the Kafka-based UC is not receiving events:
- Confirm `kafka_cluster_name` matches the cluster name configured in Guardium
- Verify the Kafka cluster is running and reachable from the Guardium Managed Units
- Check `event_delay` and `poll_interval` are appropriate for your environment
- Confirm the database was rebooted so pgAudit logging is active

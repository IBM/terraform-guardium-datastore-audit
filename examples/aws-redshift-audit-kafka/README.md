# AWS Redshift Audit with IBM Guardium Data Protection (Kafka, Connect 2.0)

This example demonstrates how to configure AWS Redshift audit logging with IBM Guardium Data Protection using the [`aws-redshift`](../../modules/aws-redshift) module and the Kafka-based `AWS Redshift Over Cloudwatch Connect 2.0` Universal Connector profile.

## Architecture

```
┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
│                     │     │                     │     │                     │     │                     │
│  AWS Redshift       │────►│  AWS CloudWatch     │────►│  Guardium Universal │────►│  Guardium Data      │
│  Cluster            │logs │  Log Groups         │poll │  Connector (Kafka,  │     │  Protection         │
│  (Connection/User)  │     │                     │     │  Connect 2.0)       │     │                     │
│                     │     │                     │     │                     │     │                     │
└─────────────────────┘     └─────────────────────┘     └─────────────────────┘     └─────────────────────┘
```

## Data Flow

1. AWS Redshift records connection and user activity logs
2. Log events are exported to CloudWatch log groups:
   - `/aws/redshift/cluster/{cluster-identifier}/connectionlog`
   - `/aws/redshift/cluster/{cluster-identifier}/useractivitylog`
3. The Guardium Kafka-based Universal Connector (`AWS Redshift Over Cloudwatch Connect 2.0`) polls CloudWatch for log events
4. Events are streamed to the Kafka cluster attached to Guardium Central Manager
5. Guardium processes, analyzes, and stores the Redshift audit events

## Overview

This Terraform configuration:

1. Creates or references CloudWatch log groups for Redshift connection and user activity logs
2. Registers the `AWS Redshift Over Cloudwatch Connect 2.0` Kafka-based Universal Connector profile in Guardium Data Protection

> **Note:** Audit setup (parameter group + CloudWatch log exports) is **not** managed by this example. Ensure your Redshift cluster already has `enable_user_activity_logging` enabled and is exporting logs to CloudWatch before applying.

## Prerequisites

Before using this example, ensure you have:

1. **AWS**:
   - An existing AWS Redshift cluster
   - AWS credentials with permissions to manage Redshift parameter groups, logging, and CloudWatch log groups

2. **Guardium Data Protection** (12.2.2 or later):
   - A running Guardium Data Protection instance with a Kafka cluster attached to Central Manager
   - An AWS credential created in Guardium Credential Management; set `udc_aws_credential`
   - Completed the one-time manual configurations as described in [Preparing Guardium Documentation](https://github.com/IBM/terraform-guardium-gdp/blob/main/docs/preparing-guardium.md):
     - OAuth client registered via `grdapi register_oauth_client`

## Usage

### 1. Create a terraform.tfvars File

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific values.

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Apply the Configuration

```bash
terraform plan
terraform apply
```

### 4. Verify the Configuration

After successful application:

1. Log in to your Guardium Data Protection web interface
2. Navigate to **Universal Connector** → **Datasource Profile Management**
3. Verify the `AWS Redshift Over Cloudwatch Connect 2.0` profile has been created and is active
4. Confirm the profile is deployed to the expected managed units

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region where Redshift cluster is deployed | `string` | `"us-east-1"` | no |
| name_prefix | Prefix for resource names | `string` | `"guardium"` | no |
| redshift_cluster_identifier | Identifier of the Redshift cluster | `string` | - | yes |
| tags | Tags to apply to all resources | `map(string)` | `{ Purpose = "guardium-redshift-kafka-uc", Owner = "your-email@example.com" }` | no |
| existing_cloudwatch_log_group_name | Name of an existing CloudWatch Log Group base to use | `string` | `""` | no |
| gdp_server | Hostname or IP address of Guardium Central Manager | `string` | - | yes |
| gdp_port | Port of Guardium Central Manager | `number` | `8443` | no |
| gdp_username | Username of Guardium Web UI user | `string` | - | yes |
| gdp_password | Password of Guardium Web UI user | `string` | - | yes |
| gdp_client_id | Client ID from `grdapi register_oauth_client` | `string` | - | yes |
| gdp_client_secret | Client secret from `grdapi register_oauth_client` | `string` | - | yes |
| gdp_mu_host | Comma-separated list of Guardium Managed Units | `string` | `"default"` | no |
| enable_universal_connector | Whether to enable the universal connector | `bool` | `true` | no |
| udc_name | Override name for the Universal Connector profile | `string` | `""` | no |
| udc_description | Description for the Universal Connector profile | `string` | `""` | no |
| udc_aws_credential | Name of the AWS credential configured in Guardium | `string` | - | yes |
| kafka_cluster_name | Kafka cluster name configured in Guardium | `string` | `"kafka"` | no |
| use_elb | Whether to use ELB for the Kafka-based Universal Connector | `bool` | `false` | no |
| filter_pattern | CloudWatch Logs filter pattern to include or exclude log events | `string` | `"None"` | no |
| database_cluster_name | Redshift cluster name in AWS console (defaults to `redshift_cluster_identifier`) | `string` | `""` | no |
| event_delay | Ingestion delay in minutes for CloudWatch log flushing | `number` | `15` | no |
| nodata_threshold_min | Minutes without events before raising no-traffic alert | `number` | `60` | no |
| poll_interval_sec | How frequently (in seconds) connector polls CloudWatch (0-59) | `string` | `"30"` | no |
| poll_interval | How frequently (in minutes) connector polls CloudWatch | `number` | `0` | no |
| event_limit | Maximum number of log events fetched per poll | `number` | `1000` | no |
| timestamp_start | Initial polling timestamp (ISO 8601, empty for current time) | `string` | `""` | no |
| unmask | When true, sensitive values (such as SQL query text) are unmasked | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| udc_name | Name of the Universal Connector |
| cloudwatch_log_group_connectionlog | Name of the CloudWatch Log Group for connection logs |
| cloudwatch_log_group_useractivitylog | Name of the CloudWatch Log Group for user activity logs |
| parameter_group_name | Name of the Redshift parameter group |
| uc_mode | Universal Connector mode |

## Troubleshooting

### Connection test fails when registering the profile
- Confirm the AWS credential specified in `udc_aws_credential` exists in Guardium Credential Management and has permissions to access CloudWatch logs.
- Confirm the CloudWatch log groups exist in the specified `aws_region`.
- Confirm the Kafka cluster attached to Guardium Central Manager is running and accessible.

### No events in Guardium
- Verify that user activity logging is enabled in the Redshift parameter group (`enable_user_activity_logging = true`).
- Verify that Redshift is exporting logs to CloudWatch (`aws redshift describe-logging-status --cluster-identifier <name>`).
- Confirm the Universal Connector profile is deployed to the expected Managed Units and active.

## Additional Resources

- [IBM Guardium Data Protection Documentation](https://www.ibm.com/docs/en/guardium)
- [Guardium Universal Connector Guide](https://www.ibm.com/docs/en/guardium/12.2?topic=connectors-universal-connector)
- [Kafka-based Redshift CloudWatch Connector Documentation](https://github.com/IBM/universal-connectors/blob/main/docs/KafkaBasedUCs/RedshiftCloudwatchKafkaConnect.md)
- [AWS Redshift Database Audit Logging](https://docs.aws.amazon.com/redshift/latest/mgmt/db-auditing.html)

## License

Copyright IBM Corp. 2026
SPDX-License-Identifier: Apache-2.0

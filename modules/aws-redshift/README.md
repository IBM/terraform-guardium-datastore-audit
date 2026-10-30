# AWS Redshift Universal Connector Module

This module configures AWS Redshift audit logging with IBM Guardium Data Protection. It supports both legacy Logstash-based (on Central Manager) and Kafka-based Universal Connector modes through the `uc_mode` variable.

**Supported Versions:** This module requires IBM Guardium Data Protection (GDP) version **12.2.1 and above** (for Kafka mode, GDP version **12.2.2 and above** with a Kafka cluster attached to Central Manager).

## Features

- Configures Redshift to send audit logs to CloudWatch Logs (or S3 for logstash mode)
- Creates two separate CloudWatch Log Groups for connection logs and user activity logs:
  - `/aws/redshift/cluster/{cluster-identifier}/connectionlog`
  - `/aws/redshift/cluster/{cluster-identifier}/useractivitylog`
- Creates necessary AWS resources (CloudWatch Log Groups, S3 bucket, parameter group)
- Automatically enables user activity logging and configures log exports
- Supports both **legacy Logstash-based** and **Kafka-based ("AWS Redshift Over Cloudwatch Connect 2.0")** Universal Connector modes

## Universal Connector Modes

This module supports two Universal Connector modes through the `uc_mode` variable:

- `logstash` - Uses the legacy Logstash Universal Connector flow (supports CloudWatch or S3)
- `kafka` - Uses the Kafka-based Universal Connector flow (**AWS Redshift Over Cloudwatch Connect 2.0**)

### Mode-specific Variables

#### Logstash mode (`uc_mode = "logstash"`)

Use these variables when running in logstash mode:

- `input_type` ("cloudwatch" or "s3")
- `existing_s3_bucket_name`
- `s3_prefix`
- `csv_start_position`
- `csv_interval`
- `csv_event_filter`
- `codec_pattern`
- `csv_description`
- `csv_cluster_name`
- `cloudwatch_endpoint`
- `use_aws_bundled_ca`

#### Kafka mode (`uc_mode = "kafka"`)

Use these variables when running in kafka mode:

- `kafka_cluster_name`
- `use_elb`
- `filter_pattern`
- `database_cluster_name`
- `event_delay`
- `nodata_threshold_min`
- `poll_interval_sec`
- `poll_interval`
- `event_limit`
- `timestamp_start`
- `unmask`

## Important: Handling Existing Log Groups

If Redshift has already created the log groups (which happens when you enable logging), you have two options:

### Option 1: Import Existing Log Groups (Recommended)

Import the existing log groups into Terraform state:

```bash
# Import connection log group
terraform import 'module.datastore-audit_aws-redshift.aws_cloudwatch_log_group.redshift_connectionlog[0]' '/aws/redshift/cluster/YOUR-CLUSTER-NAME/connectionlog'

# Import user activity log group
terraform import 'module.datastore-audit_aws-redshift.aws_cloudwatch_log_group.redshift_useractivitylog[0]' '/aws/redshift/cluster/YOUR-CLUSTER-NAME/useractivitylog'
```

Replace `YOUR-CLUSTER-NAME` with your actual Redshift cluster identifier.

### Option 2: Use Existing Log Groups

Set the `existing_cloudwatch_log_group_name` variable to the base path (without `/connectionlog` or `/useractivitylog`):

```hcl
existing_cloudwatch_log_group_name = "/aws/redshift/cluster/YOUR-CLUSTER-NAME"
```

The module will automatically append `/connectionlog` and `/useractivitylog` to this base path.

## Prerequisites

- AWS Redshift cluster
- Guardium Data Protection server (version 12.2.1 or above for Logstash, 12.2.2 or above with Kafka cluster attached for Kafka mode)
- AWS credentials with appropriate permissions

## Usage

### Kafka Mode (Recommended)

```hcl
module "redshift_audit_kafka" {
  source = "../../modules/aws-redshift"

  # General Configuration
  name_prefix = "guardium"
  aws_region  = "us-east-1"
  uc_mode     = "kafka"

  # Redshift Configuration
  redshift_cluster_identifier = "my-redshift-cluster"

  # Guardium Data Protection Configuration
  gdp_server        = "guardium.example.com"
  gdp_port          = 8443
  gdp_username      = "guardium_admin"
  gdp_password      = "your-password"
  gdp_client_id     = "your-client-id"
  gdp_client_secret = "your-client-secret"
  gdp_mu_host       = "managed-unit-1"

  # Universal Connector Configuration
  enable_universal_connector = true
  udc_aws_credential         = "aws-credential-name"

  # Kafka Configuration
  kafka_cluster_name   = "kafka"
  use_elb              = false
  event_delay          = 15
  nodata_threshold_min = 60
  poll_interval_sec    = "30"
  poll_interval        = 0
  event_limit          = 1000
  unmask               = false
}
```

### Logstash Mode (Legacy)

```hcl
module "redshift_uc" {
  source = "../../modules/aws-redshift"

  # General Configuration
  name_prefix = "guardium"
  aws_region  = "us-east-1"
  uc_mode     = "logstash"
  input_type  = "cloudwatch"  # Options: "cloudwatch" or "s3"

  # Redshift Configuration
  redshift_cluster_identifier = "my-redshift-cluster"

  # Guardium Data Protection Configuration
  gdp_server        = "guardium.example.com"
  gdp_port          = 8443
  gdp_username      = "guardium_admin"
  gdp_password      = "your-password"
  gdp_client_id     = "your-client-id"
  gdp_client_secret = "your-client-secret"
  gdp_mu_host       = "managed-unit-1"

  # Universal Connector Configuration
  enable_universal_connector = true
  udc_aws_credential         = "aws-credential-name"
}
```

## Inputs

### Common Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for resource names | `string` | `"guardium"` | no |
| aws_region | AWS region where resources will be created | `string` | `"us-east-1"` | no |
| tags | Tags to apply to all resources | `map(string)` | `{ Purpose = "guardium-redshift-uc", Owner = "your-email@example.com" }` | no |
| redshift_cluster_identifier | Identifier of the Redshift cluster | `string` | - | yes |
| uc_mode | Universal Connector mode: `logstash` or `kafka` | `string` | `"logstash"` | no |
| existing_cloudwatch_log_group_name | Name of an existing CloudWatch Log Group base to use | `string` | `""` | no |
| existing_parameter_group_name | Name of an existing parameter group to use | `string` | `""` | no |
| enable_audit_setup | Whether to configure the Redshift cluster for audit logging (parameter group + CloudWatch log exports). Set to false to only manage the Universal Connector. | `bool` | `true` | no |
| gdp_server | Hostname or IP address of Guardium Central Manager | `string` | - | yes |
| gdp_port | Port of Guardium Central Manager | `number` | `8443` | no |
| gdp_username | Username for Guardium Web UI | `string` | - | yes |
| gdp_password | Password for Guardium Web UI | `string` | - | yes |
| gdp_client_id | Client ID for Guardium OAuth | `string` | - | yes |
| gdp_client_secret | Client secret for Guardium OAuth | `string` | - | yes |
| gdp_mu_host | Comma separated list of Managed Units | `string` | `"default"` | no |
| enable_universal_connector | Whether to enable the Universal Connector | `bool` | `true` | no |
| udc_name | Override name for the Universal Connector profile | `string` | `""` | no |
| udc_description | Description for the Universal Connector profile | `string` | `""` | no |
| udc_aws_credential | AWS credential name configured in Guardium | `string` | - | yes |

### Logstash Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| input_type | Type of input for the Universal Connector (`cloudwatch` or `s3`) | `string` | `"cloudwatch"` | no |
| existing_s3_bucket_name | Name of an existing S3 bucket to use | `string` | `""` | no |
| s3_prefix | Prefix for S3 objects | `string` | `""` | no |
| csv_start_position | Start position for the Universal Connector | `string` | `"beginning"` | no |
| csv_interval | Interval for the Universal Connector | `string` | `"60"` | no |
| csv_event_filter | Event filter for the Universal Connector | `string` | `""` | no |
| codec_pattern | Codec pattern for Redshift CloudWatch logs | `string` | Complex regex pattern | no |
| csv_description | Legacy description for the Universal Connector | `string` | `"Redshift Universal Connector"` | no |
| csv_cluster_name | Cluster name for the Universal Connector | `string` | `"default"` | no |
| cloudwatch_endpoint | Custom endpoint URL for AWS CloudWatch | `string` | `""` | no |
| use_aws_bundled_ca | Whether to use AWS bundled CA certificates | `bool` | `true` | no |

### Kafka Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| kafka_cluster_name | Kafka cluster name configured in Guardium | `string` | `"kafka"` | no |
| use_elb | Whether to use ELB for Kafka-based UC | `bool` | `false` | no |
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
| s3_bucket_name | Name of the S3 bucket |
| s3_prefix | Prefix for S3 objects |
| parameter_group_name | Name of the Redshift parameter group |
| input_type | Type of input for the Universal Connector |
| uc_mode | Universal Connector mode (`logstash` or `kafka`) |

# AWS DynamoDB with Universal Connector

This example demonstrates how to configure audit logging for AWS DynamoDB using Guardium Data Protection's Universal Connector. It sets up the necessary AWS resources (CloudTrail, CloudWatch Logs, S3 bucket) to capture DynamoDB activity and configures a Universal Connector in Guardium to ingest and analyze this data.

## Architecture

```
┌───────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│                   │     │                   │     │                   │
│  AWS DynamoDB     │────►│  AWS CloudTrail   │────►│  CloudWatch Logs  │
│  Service          │     │                   │     │                   │
└───────────────────┘     └───────────────────┘     └───────────────────┘
                                                            │
                                                            │
                                                            ▼
                                                     ┌───────────────────┐
                                                     │                   │
                                                     │  Guardium         │
                                                     │  Universal        │
                                                     │  Connector        │
                                                     │                   │
                                                     └───────────────────┘
                                                            │
                                                            │
                                                            ▼
                                                     ┌───────────────────┐
                                                     │                   │
                                                     │  Guardium Data    │
                                                     │  Protection       │
                                                     │                   │
                                                     └───────────────────┘
```

## Data Flow

1. DynamoDB API calls are captured by AWS CloudTrail
2. CloudTrail logs are sent to CloudWatch Logs
3. Guardium Universal Connector reads from CloudWatch Logs
4. Guardium processes and analyzes the DynamoDB activity
5. Security teams can view and alert on DynamoDB activity in Guardium

## Prerequisites

- AWS account with DynamoDB tables
- Guardium Data Protection instance (version 12.2.1 or above)
- AWS credentials with permissions to create CloudTrail, CloudWatch Logs, S3 buckets, and IAM roles
- Terraform >= 1.0.0


### AWS Authentication Setup

Before running Terraform, ensure you have valid AWS credentials configured:

1. Validate your AWS authentication by running:
   ```bash
   aws sts get-caller-identity
   ```
   This should return your AWS account ID, user ID, and ARN.

2. If needed, configure your AWS credentials by editing `~/.aws/credentials`:
   ```
   [default]
   aws_access_key_id = YOUR_ACCESS_KEY
   aws_secret_access_key = YOUR_SECRET_KEY
   ```

## Usage

### 1. Configure the variables

Copy the provided example file to create your own configuration:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Then edit the `terraform.tfvars` file with your specific configuration:

```hcl
# AWS Configuration
aws_region  = "us-east-1"
aws_partition = "aws"
name_prefix = "dynamodb-gdp"

# DynamoDB Configuration
dynamodb_tables = "all"  # Use "all" to monitor all tables, or provide a comma-separated list

# Guardium Data Protection Connection
gdp_server = "guardium.example.com"
gdp_port   = 8443
gdp_username = "apiuser"
gdp_password = "password"
gdp_client_id = "client4"
gdp_client_secret = "client_secret123"

# Universal Connector Configuration
enable_universal_connector = true
udc_aws_credential = "guardium-aws"  # Name of the AWS credential stored in Guardium

# CSV Configuration
csv_description = "DynamoDB Universal Connector"

# Tags
tags = {
  Environment = "Production"
  Owner       = "Security Team"
  Project     = "Database Security"
}
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review the plan

```bash
terraform plan --var-file terraform.tfvars
```

### 4. Apply the configuration

```bash
terraform apply --var-file terraform.tfvars
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region where DynamoDB is deployed | `string` | `"us-east-1"` | no |
| aws_partition | AWS partition (aws, aws-cn, aws-us-gov) | `string` | `"aws"` | no |
| name_prefix | Name prefix for resources | `string` | `"dynamodb-gdp"` | no |
| gdp_server | Hostname or IP address of the Guardium Data Protection server | `string` | n/a | yes |
| gdp_port | Port for Guardium Data Protection API connection | `number` | `8443` | no |
| gdp_username | Username for Guardium API authentication | `string` | n/a | yes |
| gdp_password | Password for Guardium API authentication | `string` | n/a | yes |
| gdp_client_id | The client ID used to create the GDP register_oauth_client client_secret | `string` | `"client4"` | no |
| gdp_client_secret | The client secret output from grdapi register_oauth_client | `string` | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units to deploy profile | `string` | `""` | no |
| udc_aws_credential | The name of the AWS credential stored in Guardium Central Manager | `string` | n/a | yes |
| enable_universal_connector | Whether to enable the universal connector module | `bool` | `true` | no |
| dynamodb_tables | Comma separated list of DynamoDB tables to be monitored | `string` | `"all"` | no |
| existing_cloudtrail_name | Name of an existing CloudTrail to use | `string` | `""` | no |
| existing_cloudwatch_log_group_name | Name of an existing CloudWatch Log Group to use | `string` | `""` | no |
| csv_start_position | Start position for UDC | `string` | `"end"` | no |
| csv_interval | Polling interval for UDC | `string` | `"5"` | no |
| csv_event_filter | UDC Event filters | `string` | `""` | no |
| csv_description | UDC description | `string` | `"DynamoDB Universal Connector"` | no |
| csv_cluster_name | UDC Kafka Cluster name | `string` | `""` | no |
| tags | Tags to apply to resources created by this module | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| profile_csv | Content of the profile CSV |
| udc_name | Name of the Universal Connector |
| cloudwatch_log_group_name | Name of the CloudWatch Log Group |
| cloudwatch_log_group_arn | ARN of the CloudWatch Log Group |
| formatted_cloudwatch_logs_group_arn | Formatted ARN of the CloudWatch Log Group for CloudTrail |
| cloudtrail_name | Name of the CloudTrail |
| cloudtrail_s3_bucket | Name of the S3 bucket for CloudTrail logs |
| iam_role_arn | ARN of the IAM role for CloudTrail |
| aws_region | AWS region where DynamoDB is deployed |
| dynamodb_tables | DynamoDB tables being monitored |
| gdp_server | Hostname of the Guardium Data Protection server |
| universal_connector_enabled | Whether the Universal Connector is enabled |


## AWS Credential Configuration in Guardium

Before using this module, you need to configure AWS credentials in Guardium:

1. In the Guardium UI, navigate to Setup > Tools > AWS Authentication Configuration
2. Create a new configuration with a name (this will be your `udc_aws_credential` value)
3. Enter your AWS credentials (Access Key ID and Secret Access Key)
4. Save the configuration

# AWS Redshift Universal Connector Module

This module configures AWS Redshift to send audit logs to Guardium Data Protection using the Universal Connector.

**Supported Versions:** This module requires IBM Guardium Data Protection (GDP) version **12.2.1 and above**.

## Features

- Configures Redshift to send audit logs to CloudWatch Logs or S3
- Creates two separate CloudWatch Log Groups for connection logs and user activity logs:
  - `/aws/redshift/cluster/{cluster-identifier}/connectionlog`
  - `/aws/redshift/cluster/{cluster-identifier}/useractivitylog`
- Creates necessary AWS resources (CloudWatch Log Groups, S3 bucket, parameter group)
- Configures Guardium Data Protection Universal Connector to receive and process Redshift audit logs
- Supports both CloudWatch Logs and S3 as input sources

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
- Guardium Data Protection server (version 12.2.1 or above) with Universal Connector support
- AWS credentials with appropriate permissions

## Usage

```hcl
module "redshift_uc" {
  source = "../../modules/datastore-audit-config/aws-redshift"

  # General Configuration
  name_prefix = "guardium"
  aws_region  = "us-east-1"
  
  # Redshift Configuration
  redshift_cluster_identifier = "my-redshift-cluster"
  
  # Input Configuration (CloudWatch or S3)
  input_type = "cloudwatch"  # Options: "cloudwatch" or "s3"
  
  # Guardium Data Protection Configuration
  gdp_server             = "guardium.example.com"
  gdp_port               = 8443
  gdp_username           = "guardium_admin"
  gdp_password           = "your-password"
  gdp_client_id          = "your-client-id"
  gdp_client_secret      = "your-client-secret"
  
  # Universal Connector Configuration
  enable_universal_connector = true
  udc_aws_credential        = "aws-credential-name"
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for resource names | string | "guardium" | no |
| aws_region | AWS region where resources will be created | string | "us-east-1" | no |
| tags | Tags to apply to all resources | map(string) | { Purpose = "guardium-redshift-uc", Owner = "your-email@example.com" } | no |
| redshift_cluster_identifier | Identifier of the Redshift cluster | string | - | yes |
| input_type | Type of input for the Universal Connector (cloudwatch or s3) | string | "cloudwatch" | no |
| existing_cloudwatch_log_group_name | Name of an existing CloudWatch Log Group to use | string | "" | no |
| existing_s3_bucket_name | Name of an existing S3 bucket to use | string | "" | no |
| s3_prefix | Prefix for S3 objects | string | "" | no |
| create_parameter_group | Whether to create a parameter group for Redshift logging | bool | true | no |
| existing_parameter_group_name | Name of an existing parameter group to use | string | "" | no |
| enable_logging | Whether to enable logging for the Redshift cluster | bool | true | no |
| gdp_server | Hostname or IP address of the Guardium Data Protection server | string | - | yes |
| gdp_port | Port for the Guardium Data Protection server | number | 8443 | no |
| gdp_username | Username for the Guardium Data Protection server | string | - | yes |
| gdp_password | Password for the Guardium Data Protection server | string | - | yes |
| gdp_client_id | Client ID for the Guardium Data Protection server | string | - | yes |
| gdp_client_secret | Client secret for the Guardium Data Protection server | string | - | yes |
| gdp_mu_host | Management Unit host for the Guardium Data Protection server | string | "default" | no |
| enable_universal_connector | Whether to enable the Universal Connector | bool | true | no |
| udc_aws_credential | AWS credential name for the Universal Connector | string | - | yes |
| csv_start_position | Start position for the Universal Connector | string | "beginning" | no |
| csv_interval | Interval for the Universal Connector | string | "60" | no |
| csv_event_filter | Event filter for the Universal Connector | string | "*" | no |
| csv_description | Description for the Universal Connector | string | "Redshift Universal Connector" | no |
| csv_cluster_name | Cluster name for the Universal Connector | string | "default" | no |
| codec_pattern | Codec pattern for Redshift CloudWatch logs | string | Complex regex pattern | no |
| cloudwatch_endpoint | Custom endpoint URL for AWS CloudWatch. Leave empty to use default AWS endpoint | string | "" | no |
| use_aws_bundled_ca | Whether to use the AWS bundled CA certificates for CloudWatch connection | bool | true | no |

## Output Variables

| Name | Description |
|------|-------------|
| udc_name | Name of the Universal Connector |
| udc_csv | CSV content for the Universal Connector |
| cloudwatch_log_group_name | Name of the CloudWatch Log Group |
| s3_bucket_name | Name of the S3 bucket |
| s3_prefix | Prefix for S3 objects |
| parameter_group_name | Name of the Redshift parameter group |
| input_type | Type of input for the Universal Connector |

## Notes

- This module supports both CloudWatch Logs and S3 as input sources for the Universal Connector.
- The module automatically configures Redshift to enable user activity logging and send logs to CloudWatch or S3.
- The module can create a parameter group to enable user activity logging in Redshift, or use an existing one.
- You can use existing CloudWatch Log Groups or S3 buckets by providing their names.
- The module includes a wait mechanism to ensure the Redshift cluster is available before configuring logging.

## Automated Logging Configuration

This module automates the following steps:

1. Creates or uses an existing parameter group with user activity logging enabled
2. Applies the parameter group to the Redshift cluster
3. Waits for the Redshift cluster to become available
4. Enables CloudWatch or S3 logging based on the input_type variable
5. Configures the Universal Connector to read logs from CloudWatch or S3

You can control this behavior with the following variables:
- `enable_logging`: Set to false to disable automated logging configuration
- `create_parameter_group`: Set to false to use an existing parameter group
- `existing_parameter_group_name`: Specify the name of an existing parameter group
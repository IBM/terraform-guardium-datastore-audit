# AWS S3 Universal Connector Module (via CloudTrail)

This module configures AWS CloudTrail to capture S3 events and send them to Guardium Data Protection using the Universal Connector via CloudWatch Logs.

**Supported Versions:** This module requires IBM Guardium Data Protection (GDP) version **12.2.1 and above**.

## Features

- Creates or uses an existing CloudTrail to capture S3 data events
- Configures CloudTrail to send logs to CloudWatch Logs
- Creates necessary AWS resources (CloudTrail, CloudWatch Log Group, S3 bucket for CloudTrail logs, IAM roles)
- Configures Guardium Data Protection Universal Connector to receive and process S3 audit logs from CloudWatch
- Supports monitoring specific S3 buckets or all buckets in the account

## Prerequisites

- AWS account with appropriate permissions
- Guardium Data Protection server (version 12.2.1 or above) with Universal Connector support
- AWS credentials configured in Guardium Central Manager for CloudWatch access

## Usage

### Create New CloudTrail (Default)

```hcl
module "s3_audit" {
  source = "../../modules/aws-s3"

  # General Configuration
  name_prefix = "guardium-s3"
  aws_region  = "us-east-1"
  
  # CloudTrail Configuration
  enable_cloudtrail = true
  
  # Monitor specific S3 buckets (or use ["arn:aws:s3"] for all buckets)
  s3_bucket_arns = [
    "arn:aws:s3:::my-bucket-1/",
    "arn:aws:s3:::my-bucket-2/*"
  ]
  
  # Guardium Data Protection Configuration
  gdp_server        = "guardium.example.com"
  gdp_port          = 8443
  gdp_username      = "guardium_admin"
  gdp_password      = "your-password"
  gdp_client_id     = "your-client-id"
  gdp_client_secret = "your-client-secret"
  
  # Universal Connector Configuration
  udc_aws_credential = "aws-credential-name"
}
```

### Use Existing CloudTrail

```hcl
module "s3_audit_existing" {
  source = "../../modules/aws-s3"

  name_prefix                        = "guardium-s3"
  aws_region                         = "us-east-1"
  existing_cloudtrail_name           = "my-existing-trail"
  existing_cloudwatch_log_group_name = "/aws/cloudtrail/my-trail"
  enable_cloudtrail = false
  
  # Guardium Configuration
  gdp_server        = "guardium.example.com"
  gdp_port          = 8443
  gdp_username      = "guardium_admin"
  gdp_password      = "your-password"
  gdp_client_id     = "your-client-id"
  gdp_client_secret = "your-client-secret"
  
  # Universal Connector Configuration
  udc_aws_credential = "aws-credential-name"
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for resource names | string | "guardium-s3" | no |
| aws_region | AWS region where resources will be created | string | "us-east-1" | no |
| tags | Tags to apply to all resources | map(string) | { Purpose = "guardium-s3-uc", Owner = "your-email@example.com" } | no |
| enable_cloudtrail | Whether to enable CloudTrail for S3 audit logging | bool | true | no |
| existing_cloudtrail_name | Name of an existing CloudTrail to use | string | "" | no |
| existing_cloudwatch_log_group_name | Name of an existing CloudWatch Log Group to use | string | "" | no |
| force_destroy_bucket | Whether to force destroy the S3 bucket | bool | false | no |
| cloudwatch_logs_retention_days | Number of days to retain CloudWatch Logs | number | 7 | no |
| s3_bucket_arns | List of S3 bucket ARNs to monitor | list(string) | ["arn:aws:s3"] | no |
| include_global_service_events | Whether to include global service events in CloudTrail | bool | false | no |
| is_multi_region_trail | Whether the trail is multi-region | bool | false | no |
| include_management_events | Whether to include management events in CloudTrail | bool | false | no |
| gdp_server | Hostname or IP address of the Guardium Data Protection server | string | - | yes |
| gdp_port | Port for the Guardium Data Protection server | number | 8443 | no |
| gdp_username | Username for the Guardium Data Protection server | string | - | yes |
| gdp_password | Password for the Guardium Data Protection server | string | - | yes |
| gdp_client_id | Client ID for the Guardium Data Protection server | string | - | yes |
| gdp_client_secret | Client secret for the Guardium Data Protection server | string | - | yes |
| gdp_mu_host | Comma-separated list of Guardium Managed Units | string | "" | no |
| enable_universal_connector | Whether to enable the Universal Connector | bool | true | no |
| udc_aws_credential | AWS credential name for the Universal Connector | string | - | yes |
| udc_start_position | Start position for the Universal Connector | string | "end" | no |
| udc_interval | Interval for the Universal Connector (in seconds) | string | "5" | no |
| udc_event_filter | Event filter for the Universal Connector | string | "{$.eventSource=\"s3.amazonaws.com\"}" | no |
| udc_prefix | Prefix for the Universal Connector | string | "" | no |
| udc_unmask | Whether to unmask sensitive data | string | "false" | no |
| udc_endpoint | Custom endpoint URL for AWS CloudWatch | string | "" | no |
| udc_use_aws_bundled_ca | Whether to use the AWS bundled CA certificates | string | "true" | no |
| udc_description | Description for the Universal Connector | string | "S3 Universal Connector via CloudTrail" | no |

## Output Variables

| Name | Description |
|------|-------------|
| profile_csv | Content of the profile CSV |
| udc_name | Name of the Universal Connector |
| cloudtrail_name | Name of the CloudTrail |
| cloudtrail_arn | ARN of the CloudTrail |
| cloudwatch_log_group_name | Name of the CloudWatch Log Group |
| cloudwatch_log_group_arn | ARN of the CloudWatch Log Group |
| formatted_cloudwatch_logs_group_arn | Formatted ARN of the CloudWatch Log Group for CloudTrail |
| s3_bucket_name | Name of the S3 bucket for CloudTrail logs |
| s3_bucket_arn | ARN of the S3 bucket for CloudTrail logs |
| iam_role_arn | ARN of the IAM role for CloudTrail |
| aws_account_id | AWS Account ID |
| aws_region | AWS Region |

## How It Works

1. **CloudTrail**: Captures S3 data events (GetObject, PutObject, DeleteObject, etc.)
2. **CloudWatch Logs**: CloudTrail sends events to a CloudWatch Log Group
3. **Universal Connector**: Reads S3 events from CloudWatch Logs and sends them to Guardium

## Monitoring Specific Buckets

To monitor specific S3 buckets instead of all buckets:

```hcl
s3_bucket_arns = [
  "arn:aws:s3:::my-sensitive-bucket/",
  "arn:aws:s3:::my-audit-bucket/*"
]
```

To monitor all buckets (default):

```hcl
s3_bucket_arns = ["arn:aws:s3"]
```

## Notes

- CloudTrail captures S3 data events, which include object-level API operations
- The default event filter `{$.eventSource="s3.amazonaws.com"}` ensures only S3 events are processed
- CloudTrail logs are stored in an S3 bucket for compliance and backup purposes
- The module creates necessary IAM roles and policies for CloudTrail to write to CloudWatch Logs
- Consider costs: CloudTrail data events can generate significant volume for high-traffic buckets

## Cost Considerations

- CloudTrail data events are charged per event (first 2 million events free per month)
- CloudWatch Logs storage and ingestion have associated costs
- Consider using lifecycle policies on the CloudTrail S3 bucket to manage long-term storage costs

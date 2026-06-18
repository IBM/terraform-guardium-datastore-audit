# AWS S3 Audit Example (via CloudTrail)

This example demonstrates how to configure AWS S3 audit logging with Guardium Data Protection using CloudTrail and the Universal Connector.

## Overview

This example creates:
- CloudTrail to capture S3 data events
- CloudWatch Log Group for CloudTrail logs
- S3 bucket for CloudTrail log storage
- IAM roles and policies for CloudTrail
- Universal Connector configuration in Guardium Data Protection

Alternatively, you can use existing CloudTrail and CloudWatch Log Group resources.

## Prerequisites

- AWS account with appropriate permissions
- Guardium Data Protection server (version 12.2.1 or above)
- AWS credentials configured in Guardium Central Manager
- Terraform >= 1.0.0

## Usage

1. Copy the example configuration:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your specific values:
   - AWS region
   - S3 buckets to monitor (specific buckets or all)
   - Guardium Data Protection server details
   - AWS credential name (as configured in Guardium)

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Review the planned changes:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

## Configuration Options

### Monitoring Scope

**Monitor All S3 Buckets (Default):**
```hcl
s3_bucket_arns = ["arn:aws:s3"]
```

**Monitor Specific Buckets:**
```hcl
s3_bucket_arns = [
  "arn:aws:s3:::my-sensitive-bucket/*",
  "arn:aws:s3:::my-audit-bucket/*"
]
```

### CloudTrail Configuration

- **New CloudTrail**: Set `enable_cloudtrail = true` and comment out `existing_cloudtrail_name` and `existing_cloudwatch_log_group_name`
- **Existing CloudTrail**: Set `existing_cloudtrail_name` to use an existing trail and set `enable_cloudtrail = false` 
- **Existing CloudWatch Log Group**: Set `existing_cloudwatch_log_group_name` to use an existing log group

### Event Filtering

The default event filter `{$.eventSource="s3.amazonaws.com"}` ensures only S3 events are captured. This includes:
- GetObject
- PutObject
- DeleteObject
- CopyObject
- And other S3 API operations

## Example Configuration

### Create New CloudTrail

```hcl
# Basic configuration
name_prefix       = "guardium-s3"
aws_region        = "us-east-1"
enable_cloudtrail = true

# Monitor specific buckets
s3_bucket_arns = [
  "arn:aws:s3:::my-sensitive-data/*",
  "arn:aws:s3:::my-compliance-bucket/*"
]

# Guardium configuration
gdp_server        = "guardium.example.com"
gdp_port          = 8443
gdp_username      = "admin"
gdp_password      = "password"
gdp_client_id     = "client4"
gdp_client_secret = "client-secret"
udc_aws_credential = "guardium-aws"
```

### Use Existing CloudTrail

```hcl
name_prefix                        = "guardium-s3"
aws_region                         = "us-east-1"
existing_cloudtrail_name           = "my-existing-trail"
existing_cloudwatch_log_group_name = "/aws/cloudtrail/my-trail"

# Guardium configuration
gdp_server        = "guardium.example.com"
gdp_port          = 8443
gdp_username      = "admin"
gdp_password      = "password"
gdp_client_id     = "client4"
gdp_client_secret = "client-secret"
udc_aws_credential = "guardium-aws"
```

## Outputs

After applying, the following outputs are available:

- `udc_name`: Name of the Universal Connector
- `cloudtrail_name`: Name of the CloudTrail
- `cloudtrail_arn`: ARN of the CloudTrail
- `cloudwatch_log_group_name`: Name of the CloudWatch Log Group
- `cloudwatch_log_group_arn`: ARN of the CloudWatch Log Group
- `s3_bucket_name`: Name of the S3 bucket for CloudTrail logs
- `s3_bucket_arn`: ARN of the S3 bucket for CloudTrail logs
- `iam_role_arn`: ARN of the IAM role for CloudTrail
- `aws_account_id`: AWS Account ID
- `aws_region`: AWS Region

## How It Works

1. **CloudTrail** captures S3 data events (object-level API operations)
2. **CloudWatch Logs** receives events from CloudTrail in real-time
3. **Universal Connector** reads S3 events from CloudWatch Logs
4. **Guardium** processes and stores the audit data

## Notes

- CloudTrail data events can generate significant volume for high-traffic buckets
- Consider costs: CloudTrail charges per event, CloudWatch Logs charges for storage/ingestion
- The CloudTrail logs are also stored in S3 for compliance and backup
- Event filter ensures only S3-related events are processed by Guardium
- Start position is set to "end" to avoid processing historical logs

## Cost Considerations

- **CloudTrail**: Charged per data event (first 2 million events free per month)
- **CloudWatch Logs**: Charged for ingestion and storage
- **S3 Storage**: Charged for CloudTrail log storage
- Consider using lifecycle policies on the CloudTrail S3 bucket

## Cleanup

To destroy the resources:

```bash
terraform destroy
```

**Warning**: If `force_destroy_bucket` is set to `false` (default), you must manually empty the S3 bucket before destroying it.

## Support

For issues or questions, please refer to the main module documentation or contact your Guardium administrator.

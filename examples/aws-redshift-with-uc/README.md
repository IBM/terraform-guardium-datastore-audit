# AWS Redshift with Universal Connector Example

This example demonstrates how to configure AWS Redshift to send audit logs to Guardium Data Protection using the Universal Connector.

## Features

- Configures Redshift to send audit logs to CloudWatch Logs or S3
- Creates two separate CloudWatch Log Groups for connection logs and user activity logs:
  - `/aws/redshift/cluster/{cluster-identifier}/connectionlog`
  - `/aws/redshift/cluster/{cluster-identifier}/useractivitylog`
- Creates necessary AWS resources (CloudWatch Log Groups, S3 bucket, parameter group)
- Configures Guardium Data Protection Universal Connector to receive and process Redshift audit logs
- Supports both CloudWatch Logs and S3 as input sources

## Prerequisites

- AWS Redshift cluster
- Guardium Data Protection server (version 12.2.1 or above) with Universal Connector support
- AWS credentials with appropriate permissions

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values to match your environment:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Update the `terraform.tfvars` file with your specific configuration:

```hcl
# General Configuration
name_prefix = "guardium"
aws_region  = "us-east-1"

# Redshift Configuration
redshift_cluster_identifier = "my-redshift-cluster"

# Input Configuration
input_type = "cloudwatch"  # Options: "cloudwatch" or "s3"

# Guardium Data Protection Configuration
gdp_server             = "guardium.example.com"
gdp_port               = 8443
gdp_username           = "guardium_admin"
gdp_password           = "your-password"
gdp_client_id          = "your-client-id"
gdp_client_secret      = "your-client-secret"

# Universal Connector Configuration
udc_aws_credential     = "aws-credential-name"
```

3. Initialize Terraform:

```bash
terraform init
```

4. Apply the Terraform configuration:

```bash
terraform apply
```

## Notes

- This example supports both CloudWatch Logs and S3 as input sources for the Universal Connector.
- The module automatically configures Redshift to enable user activity logging and send logs to CloudWatch or S3.
- When using CloudWatch, the module creates two separate log groups with the required naming pattern:
  - One ending with `/connectionlog` for connection logs
  - One ending with `/useractivitylog` for user activity logs
- You can use existing CloudWatch Log Groups or S3 buckets by providing their names (ensure they follow the required naming pattern).
- You can use an existing parameter group by setting `create_parameter_group = false` and providing `existing_parameter_group_name`.
- The module includes a wait mechanism to ensure the Redshift cluster is available before configuring logging.

## Handling Existing Log Groups

If you encounter an error that the log groups already exist (e.g., if Redshift already created them), you have two options:

### Option 1: Import Existing Log Groups into Terraform State

Run these commands from the example directory:

```bash
# Import connection log group
terraform import 'module.datastore-audit_aws-redshift.aws_cloudwatch_log_group.redshift_connectionlog[0]' '/aws/redshift/cluster/YOUR-CLUSTER-NAME/connectionlog'

# Import user activity log group
terraform import 'module.datastore-audit_aws-redshift.aws_cloudwatch_log_group.redshift_useractivitylog[0]' '/aws/redshift/cluster/YOUR-CLUSTER-NAME/useractivitylog'
```

Replace `YOUR-CLUSTER-NAME` with your actual Redshift cluster identifier (e.g., `guardium-redshift`).

After importing, run `terraform apply` again.

### Option 2: Configure to Use Existing Log Groups

Add this to your `terraform.tfvars`:

```hcl
existing_cloudwatch_log_group_name = "/aws/redshift/cluster/YOUR-CLUSTER-NAME"
```

The module will automatically append `/connectionlog` and `/useractivitylog` to this base path and use the existing log groups instead of trying to create new ones.

## Automated Logging Configuration

This example includes automated configuration of Redshift logging:

1. It enables user activity logging by modifying the parameter group
2. It configures Redshift to send logs to CloudWatch or S3 based on the input_type
3. It waits for the Redshift cluster to become available between operations
4. It configures the Universal Connector to read logs from the configured destination

You can control this behavior with the following variables in terraform.tfvars:
```hcl
# Parameter Group Configuration
create_parameter_group = false  # Use an existing parameter group
existing_parameter_group_name = "your-parameter-group"  # Name of your existing parameter group
enable_logging = true  # Enable automated logging configuration
```

## Additional Resources

For more detailed information about the Redshift Universal Connector, refer to the [Redshift-Guardium Logstash filter plug-in documentation](https://github.com/IBM/universal-connectors/tree/main/filter-plugin/logstash-filter-redshift-aws-guardium).
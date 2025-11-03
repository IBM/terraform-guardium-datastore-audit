# AWS Redshift with Universal Connector Example

This example demonstrates how to configure AWS Redshift to send audit logs to Guardium Data Protection using the Universal Connector.

## Features

- Configures Redshift to send audit logs to CloudWatch Logs or S3
- Creates necessary AWS resources (CloudWatch Log Group, S3 bucket, parameter group)
- Configures Guardium Data Protection Universal Connector to receive and process Redshift audit logs
- Supports both CloudWatch Logs and S3 as input sources

## Prerequisites

- AWS Redshift cluster
- Guardium Data Protection server with Universal Connector support
- AWS credentials with appropriate permissions
- SSH access to the Guardium Data Protection server

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
gdp_ssh_username       = "ec2-user"
gdp_ssh_privatekeypath = "~/.ssh/id_rsa"

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
- You can use existing CloudWatch Log Groups or S3 buckets by providing their names.
- You can use an existing parameter group by setting `create_parameter_group = false` and providing `existing_parameter_group_name`.
- The module includes a wait mechanism to ensure the Redshift cluster is available before configuring logging.

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
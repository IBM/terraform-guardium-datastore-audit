# AWS DocumentDB with Universal Connector Example

This example demonstrates how to configure AWS DocumentDB with IBM Guardium Data Protection using the Universal Connector for comprehensive audit logging and monitoring.

## Overview

This Terraform configuration:

1. Configures an existing AWS DocumentDB cluster for audit logging
2. Sets up a Universal Data Connector in Guardium to collect and analyze DocumentDB audit logs from CloudWatch
3. Enables comprehensive monitoring of database operations, user activity, and access patterns

## Prerequisites

Before using this example, ensure you have:

1. **AWS Resources**:
   - An existing AWS DocumentDB cluster

2. **Guardium Data Protection**:
   - A running Guardium Data Protection instance
   - Completed the one-time manual configurations as described in [Preparing Guardium Documentation](https://github.com/IBM/terraform-guardium-gdp/blob/main/docs/preparing-guardium.md):
     - OAuth client registered via `grdapi register_oauth_client`
     - AWS credentials configured in Guardium Data Protection
     - SSH access configured for Terraform

## Usage

### 1. Create a terraform.tfvars File

Create a `terraform.tfvars` file with your specific configuration values:

```hcl
# AWS Configuration
aws_region = "us-east-1"
documentdb_cluster_identifier = "your-documentdb-cluster-id"

# Guardium Configuration
gdp_server = "guardium.example.com"
gdp_username = "guardium-user"
gdp_password = "guardium-password"
gdp_ssh_username = "guardium-ssh-user"
gdp_ssh_privatekeypath = "/path/to/private/key"
gdp_client_id = "client1"
gdp_client_secret = "client-secret-value"
udc_aws_credential = "aws-credential-name"
gdp_mu_host = "mu1,mu2"

# Optional Configuration
csv_interval = "30"  # Polling interval in seconds

# Resource Tags
tags = {
  Environment = "Production"
  Owner       = "Security Team"
}
```
### 3. Import the documentdb parameter group
```
terraform import -var-file=terraform.tfvars 'module.datastore-audit_aws-documentdb.aws_docdb_cluster_parameter_group.guardium' <parameter group name>
```

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Apply the Configuration

```bash
terraform apply --var-file terraform.tfvars
```

Review the planned changes and type `yes` to apply them.

### 6. Verify the Configuration

After successful application:

1. Log in to your Guardium Data Protection web interface
2. Navigate to **Universal Connector** → **Datasource Profile Management**
3. Verify that the DocumentDB profile has been created and is active
4. Navigate to **Cloudwatch** → **Log Groups** on the AWS UI and search for `/aws/docdb/<docdb_cluster_id>`. You should see log groups created
5. Navigate to the machine unit the UC is deployed on and ensure the STAP status is green.

## Parameter Group Management

The module intelligently handles DocumentDB parameter groups:

- If the cluster uses a default parameter group, it creates a new custom parameter group
- If the cluster already uses a custom parameter group, it modifies that group
- Parameter changes include enabling audit logs and profiler with appropriate settings

## CloudWatch Integration

The module configures DocumentDB to send audit logs to CloudWatch Logs. The Universal Connector then:

1. Reads these logs from CloudWatch using the configured AWS credentials
2. Parses and normalizes the log data
3. Forwards the processed audit events to Guardium for analysis

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region where resources will be created | `string` | `"us-east-1"` | no |
| documentdb_cluster_identifier | DocumentDB cluster identifier to be monitored | `string` | n/a | yes |
| udc_name | Name for universal connector (used for AWS objects) | `string` | `"documentdb-gdp"` | no |
| udc_aws_credential | Name of AWS credential defined in Guardium | `string` | n/a | yes |
| gdp_client_id | Client ID used when running grdapi register_oauth_client | `string` | n/a | yes |
| gdp_client_secret | Client secret from output of grdapi register_oauth_client | `string` | n/a | yes |
| gdp_server | Hostname/IP address of Guardium Central Manager | `string` | n/a | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"` | no |
| gdp_username | Username of Guardium Web UI user | `string` | n/a | yes |
| gdp_password | Password of Guardium Web UI user | `string` | n/a | yes |
| gdp_ssh_username | Guardium OS user with SSH access | `string` | n/a | yes |
| gdp_ssh_privatekeypath | Private SSH key to connect to Guardium OS | `string` | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units to deploy profile | `string` | n/a | yes |
| csv_interval | Polling interval in seconds for checking new logs | `string` | `"30"` | no |
| tags | Map of tags to apply to resources | `map(string)` | n/a | yes |

# AWS Aurora MySQL Audit Module

This module configures Guardium Data Protection to monitor an existing AWS Aurora MySQL cluster via CloudWatch logs.

## Overview

This module:
- Connects to an existing Aurora MySQL cluster
- Registers the cluster with Guardium via Universal Connector
- Monitors audit logs exported to CloudWatch

## Prerequisites

- Existing Aurora MySQL cluster with audit logging enabled
- CloudWatch log exports configured on the cluster
- AWS credentials configured in Guardium
- Guardium Data Protection instance with API access

## Usage

```hcl
module "aurora_mysql_audit" {
  source = "IBM/datastore-audit/guardium//modules/aws-aurora-mysql"

  # AWS Configuration
  aws_region                      = "us-east-1"
  aurora_mysql_cluster_identifier = "my-aurora-mysql-cluster"
  cloudwatch_logs_exports         = ["audit"]

  # Guardium Configuration
  udc_aws_credential = "my-aws-credential"
  gdp_client_id      = "my-client-id"
  gdp_client_secret  = "my-client-secret"
  gdp_server         = "guardium.example.com"
  gdp_username       = "admin"
  gdp_password       = "password"
  gdp_mu_host        = "managed-unit-1"

  # Universal Connector Settings
  enable_universal_connector = true
  csv_start_position        = "end"
  csv_interval              = "5"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region where the Aurora MySQL cluster is deployed | `string` | `"us-east-1"` | no |
| aurora_mysql_cluster_identifier | Aurora MySQL cluster identifier to be monitored | `string` | `"guardium-aurora-mysql"` | no |
| cloudwatch_logs_exports | List of log types to monitor (audit, error, general, slowquery) | `list(string)` | `["audit"]` | no |
| udc_aws_credential | Name of AWS credential defined in Guardium | `string` | n/a | yes |
| gdp_client_id | Client ID from Guardium OAuth registration | `string` | n/a | yes |
| gdp_client_secret | Client secret from Guardium OAuth registration | `string` | n/a | yes |
| gdp_server | Hostname/IP of Guardium Central Manager | `string` | n/a | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"` | no |
| gdp_username | Guardium Web UI username | `string` | n/a | yes |
| gdp_password | Guardium Web UI password | `string` | n/a | yes |
| gdp_mu_host | Comma-separated list of Guardium Managed Units | `string` | `""` | no |
| enable_universal_connector | Whether to enable the universal connector | `bool` | `true` | no |
| csv_start_position | Start position for log reading (beginning or end) | `string` | `"end"` | no |
| csv_interval | Polling interval in seconds | `string` | `"5"` | no |
| csv_event_filter | Event filters for the connector | `string` | `""` | no |
| codec_pattern | Codec pattern for log parsing | `string` | `""` | no |
| cloudwatch_endpoint | Custom CloudWatch endpoint URL | `string` | `""` | no |
| use_aws_bundled_ca | Use AWS bundled CA certificates | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| udc_name | Universal connector name |
| log_group | CloudWatch log group(s) being monitored |
| aws_account_id | AWS Account ID |
| aws_region | AWS Region |

## CloudWatch Log Groups

The module monitors CloudWatch log groups with the following naming pattern:

```
/aws/rds/cluster/<cluster-identifier>/audit
```

## Importing Existing Parameter Groups

If your Aurora MySQL cluster already uses a custom parameter group that you want to manage with Terraform, you can import it into the Terraform state. This prevents Terraform from trying to create a new parameter group and allows you to manage the existing one.

### Steps to Import

1. **Identify the parameter group name** attached to your Aurora MySQL cluster:
   ```bash
   aws rds describe-db-clusters --db-cluster-identifier <cluster-identifier> \
     --query 'DBClusters[0].DBClusterParameterGroup' --output text
   ```

2. **Import the parameter group** into Terraform state:
   ```bash
   terraform import 'module.datastore-audit_aws-aurora-mysql.module.common_aurora-mysql-parameter-group.aws_rds_cluster_parameter_group.aurora_mysql_param_group' <parameter-group-name>
   ```

3. **Run terraform plan** to verify the import was successful and check for any configuration drift:
   ```bash
   terraform plan
   ```

### Example

```bash
# Get the parameter group name
aws rds describe-db-clusters --db-cluster-identifier my-aurora-mysql-cluster \
  --query 'DBClusters[0].DBClusterParameterGroup' --output text

# Output: my-custom-aurora-mysql-pg

# Import the parameter group
terraform import 'module.datastore-audit_aws-aurora-mysql.module.common_aurora-mysql-parameter-group.aws_rds_cluster_parameter_group.aurora_mysql_param_group' my-custom-aurora-mysql-pg

# Verify
terraform plan
```

### Important Notes

- The module automatically detects if the cluster is using the default parameter group and creates a new custom one if needed
- If a custom parameter group already exists, the module will update it with the required audit parameters
- Importing is only necessary if you want to avoid Terraform recreating an existing custom parameter group
- After importing, Terraform will manage the parameter group and may update parameters to match the module configuration

## Notes

- Ensure the Aurora MySQL cluster has `enabled_cloudwatch_logs_exports` configured
- The cluster must have audit logging enabled via parameter groups
- AWS credentials must be pre-configured in Guardium before running this module
- The module only registers the cluster with Guardium; it does not create the cluster

## Example with Multiple Log Types

```hcl
module "aurora_mysql_audit" {
  source = "IBM/datastore-audit/guardium//modules/aws-aurora-mysql"

  aurora_mysql_cluster_identifier = "production-mysql"
  cloudwatch_logs_exports         = ["audit"]
  
  # ... other required variables
}
```

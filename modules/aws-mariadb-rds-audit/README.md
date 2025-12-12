# AWS MariaDB RDS Audit Configuration

This module configures audit logging for MariaDB RDS instances with IBM Guardium Data Protection. It enables the MariaDB Audit Plugin through an option group and configures log collection via CloudWatch.

## Prerequisites

Before using this module, you need to:

1. Have an existing MariaDB RDS instance
2. Have Guardium set up with appropriate credentials
3. **Important**: You must initialize Terraform and import the existing parameter and option group before applying this module

## Guardium Data Protection Version Compatibility

**Important:** The upload method for Universal Connector profiles depends on your Guardium Data Protection (GDP) version:

- **GDP 12.2.1 and above**: Use API-based upload by setting `use_multipart_upload = true` (default and recommended)
- **GDP versions below 12.2.1**: Use SFTP-based upload by setting `use_multipart_upload = false`

When using SFTP (`use_multipart_upload = false`), you must also provide `gdp_ssh_username` and `gdp_ssh_privatekeypath` for authentication.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |
| guardium-data-protection | >= 1.0.0 |

### Option Group and Parameter Group Import Process

This module uses existing option group to enable the `MariaDB Audit Plugin` and existing parameter group.
To ensure Terraform manages your RDS instance correctly:

1. Initialize Terraform in your working directory:
   ```bash
   terraform init
   ```

2. Identify your current parameter group:
   ```bash
   aws rds describe-db-instances \
   --db-instance-identifier your-mariadb-instance \
   --region your-region \
   --query "DBInstances[0].DBParameterGroups[0].DBParameterGroupName" \
   --output text
   ```

3. Import your current parameter group:
   ```bash
   terraform import module.common_rds-mariadb-mysql-parameter-group.aws_db_parameter_group.db_param_group <your-parameter-group-name>
   ```

4. Identify your current option group name:
   ```bash
   aws rds describe-db-instances \
     --db-instance-identifier your-mariadb-instance \
     --region your-region \
     --query "DBInstances[0].OptionGroupMemberships[0].OptionGroupName" \
     --output text
   ```

5. Import the option group into Terraform state:
   ```bash
   terraform import module.common_rds-mariadb-mysql-parameter-group.aws_db_option_group.audit <your-option-group-name>
   ```

**Note**: Skipping the import steps will cause Terraform to attempt creating a new parameter group, which may fail or cause unexpected behavior.

## Features

- Configures MariaDB RDS for audit logging
- Configures audit events to capture (CONNECT, QUERY, etc.)
- Integrates with Guardium for audit data collection via CloudWatch

## Usage

### Using a tfvars File

Create a `defaults.tfvars` file with your configuration. See [terraform.tfvars.example](./terraform.tfvars.example) for an example with available options and detailed comments.

Then run:

```bash
# Import existing resources (required)
# See the "Option Group and Parameter Group Import Process" section above

# Plan the changes
terraform plan -var-file=defaults.tfvars

# Apply the changes
terraform apply -var-file=defaults.tfvars
```

## Provider Configuration

This module requires both the AWS provider and the Guardium Data Protection provider.
The providers are configured automatically using the variables you provide:

```hcl
provider "aws" {
  region = var.aws_region
}

provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}
```

Make sure your Terraform environment has access to the Guardium Data Protection provider, which is sourced from:
```
na.artifactory.swg-devops.com/ibm/guardium-data-protection
```

## Module Dependencies

This module uses the following internal modules:

1. `aws-configuration` - Retrieves AWS account information
2. `rds-mariadb-mysql-parameter-group` - Configures the MariaDB parameter group for audit logging
3. `rds-mariadb-mysql-cloudwatch-registration` - Sets up CloudWatch integration for audit logs (when using CloudWatch)

## Audit Events Configuration

The `audit_events` variable allows you to specify which events to audit:

```hcl
audit_events = "CONNECT,QUERY,TABLE,QUERY_DDL,QUERY_DML,QUERY_DCL"
```

Valid audit event options:
- CONNECT: Connection events
- QUERY: All queries
- TABLE: Table access events
- QUERY_DDL: Data Definition Language queries
- QUERY_DML: Data Manipulation Language queries
- QUERY_DCL: Data Control Language queries

## CloudWatch Integration

This module configures CloudWatch integration for MariaDB RDS auditing. The audit logs are sent to a CloudWatch log group with the format:

```
/aws/rds/instance/<mariadb_rds_cluster_identifier>/audit
```

Guardium is configured to collect and analyze these logs.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region | string | `"us-east-2"` | no |
| mariadb_rds_cluster_identifier | MariaDB RDS cluster identifier | string | `"guardium-mariadb"` | no |
| audit_events | Comma-separated list of events to audit | string | `"CONNECT,QUERY"` | no |
| audit_file_rotations | Number of audit file rotations to keep | string | `"10"` | no |
| audit_file_rotate_size | Size in bytes before rotating audit file | string | `"1000000"` | no |
| audit_incl_users | Comma-separated list of users to include in audit logs (SERVER_AUDIT_INCL_USERS). If set, only these users will be audited. Leave empty to audit all users. | string | `""` | no |
| audit_excl_users | Comma-separated list of users to exclude from audit logs (SERVER_AUDIT_EXCL_USERS). The rdsadmin user queries the database every second for health checks, which can cause log files to grow quickly. | string | `"rdsadmin"` | no |
| audit_query_log_limit | Maximum query length to log in bytes (SERVER_AUDIT_QUERY_LOG_LIMIT). Queries longer than this will be truncated. | string | `"1024"` | no |
| cloudwatch_logs_exports | List of log types to export to CloudWatch. Valid value for MariaDB: audit | list(string) | `["audit"]` | no |
| udc_aws_credential | Name of AWS credential defined in Guardium | string | n/a | yes |
| gdp_client_secret | Client secret from Guardium | string | n/a | yes |
| gdp_client_id | Client ID from Guardium | string | n/a | yes |
| gdp_server | Guardium server hostname/IP | string | n/a | yes |
| gdp_port | Port of Guardium Central Manager | string | `"8443"` | no |
| gdp_username | Guardium username | string | n/a | yes |
| gdp_password | Guardium password | string | n/a | yes |
| gdp_ssh_username | Guardium SSH username (required when use_multipart_upload = false) | string | n/a | conditional |
| gdp_ssh_privatekeypath | Path to SSH private key (required when use_multipart_upload = false) | string | n/a | conditional |
| gdp_mu_host | Comma separated list of Guardium Managed Units | string | `""` | no |
| log_export_type | Log export type (Cloudwatch) | string | `"Cloudwatch"` | no |
| force_failover | Whether to force failover during option group update | bool | `false` | no |
| tags | Map of tags to apply to resources | map(string) | `{}` | no |
| udc_name | Name for universal connector | string | `"mariadb-gdp"` | no |
| enable_universal_connector | Whether to enable the universal connector | bool | `true` | no |
| csv_start_position | Start position for UDC | string | `"end"` | no |
| csv_interval | Polling interval for UDC | string | `"5"` | no |
| csv_event_filter | UDC Event filters | string | `""` | no |
| cloudwatch_endpoint | Custom endpoint URL for AWS CloudWatch. Leave empty to use default AWS endpoint | string | `""` | no |
| use_aws_bundled_ca | Whether to use the AWS bundled CA certificates for CloudWatch connection | bool | `true` | no |
| use_multipart_upload | Use API upload (true, for GDP 12.2.1+) or SFTP (false, for GDP < 12.2.1) | bool | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| udc_name | Name of the Universal Connector |
| cloudwatch_log_group | Name of the CloudWatch Log Group for audit logs |
| parameter_group_name | Name of the RDS parameter group |
| option_group_name | Name of the RDS option group with audit plugin |
| aws_region | AWS region where resources are deployed |
| aws_account_id | AWS account ID |
| rds_cluster_identifier | RDS cluster identifier |
| log_export_type | Type of log export |

# AWS MySQL RDS with IBM Guardium Data Protection

This example demonstrates how to configure AWS MySQL RDS with IBM Guardium Data Protection using audit logging for comprehensive monitoring.

## Architecture

```
┌───────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│                   │     │                   │     │                   │
│  AWS MySQL RDS    │────►│  MariaDB Audit    │────►│  CloudWatch Logs  │
│  Instance         │     │  Plugin           │     │                   │
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

1. MySQL RDS database activity is captured by the MariaDB Audit Plugin
2. Audit logs are sent to CloudWatch Logs
3. Guardium Universal Connector reads from CloudWatch Logs
4. Guardium processes and analyzes the MySQL activity
5. Security teams can view and alert on MySQL activity in Guardium

## Overview

This Terraform configuration:

1. Configures an existing AWS MySQL RDS instance for audit logging
2. Sets up a Universal Data Connector in Guardium to collect and analyze MySQL audit logs from CloudWatch
3. Enables comprehensive monitoring of database operations, user activity, and access patterns

## Prerequisites

Before using this example, ensure you have:

1. **AWS Resources**:
  - An existing AWS MySQL RDS instance

2. **Guardium Data Protection**:
  - A running Guardium Data Protection instance
  - Completed the one-time manual configurations as described in [Preparing Guardium Documentation](https://github.com/IBM/terraform-guardium-gdp/blob/main/docs/preparing-guardium.md):
    - OAuth client registered via `grdapi register_oauth_client`
    - AWS credentials configured in Guardium Data Protection
    - SSH access configured for Terraform

## Usage

### 1. Create a terraform.tfvars File

Create a `defaults.tfvars` file with your configuration. See [terraform.tfvars.example](./terraform.tfvars.example) for an example with available options and detailed comments.

### 2. Initialize Terraform

  ```bash
  terraform init
  ```

### 3. Import the MySQL Parameter Group and Option Group

Identify existing parameter group name:

  ```bash
  # Get current parameter group name
  aws rds describe-db-instances \
    --db-instance-identifier your-mysql-instance \
    --region your-region \
    --query "DBInstances[0].DBParameterGroups[0].DBParameterGroupName" \
    --output text
  ```

Import existing parameter group:
   ```bash
   terraform import module.datastore-audit_aws-mysql-rds-audit.module.common_rds-mariadb-mysql-parameter-group.aws_db_parameter_group.db_param_group <your-parameter-group-name>
   ```

Identify existing option group name:

  ```bash
  # Get current option group name
  aws rds describe-db-instances \
    --db-instance-identifier your-mysql-instance \
    --region your-region \
    --query "DBInstances[0].OptionGroupMemberships[0].OptionGroupName" \
    --output text
  ```

Import existing option group:
   ```bash
   terraform import module.datastore-audit_aws-mysql-rds-audit.module.common_rds-mariadb-mysql-parameter-group.aws_db_option_group.audit <your-option-group-name>
   ```

**Note**: Skipping the import steps will cause Terraform to attempt creating a new parameter group, which may fail or cause unexpected behavior.

### 4. Apply the Configuration

  ```bash
  terraform apply -var-file=defaults.tfvars
  ```

Review the planned changes and type `yes` to apply them.

### 5. Verify the Configuration

After successful application:

1. Log in to your Guardium Data Protection web interface
2. Navigate to **Universal Connector** → **Datasource Profile Management**
3. Verify that the MySQL profile has been created and is active
4. Navigate to **CloudWatch** → **Log Groups** on the AWS UI and search for `/aws/rds/instance/<mysql_instance_id>/audit`. You should see log groups created
5. Navigate to the machine unit the UC is deployed on and ensure the STAP status is green/active

## CloudWatch Integration

The module configures MySQL RDS to send audit logs to CloudWatch Logs. The Universal Connector then:

1. Reads these logs from CloudWatch using the configured AWS credentials
2. Parses and normalizes the log data
3. Forwards the processed audit events to Guardium for analysis

## Audit Events Configuration

You can configure which events to audit using the `audit_events` variable:

- `CONNECT`: Connection events
- `QUERY`: All queries
- `TABLE`: Table access events
- `QUERY_DDL`: Data Definition Language queries
- `QUERY_DML`: Data Manipulation Language queries
- `QUERY_DCL`: Data Control Language queries

## Input Variables

| Name | Description | Type | Default            | Required |
|------|-------------|------|--------------------|:--------:|
| aws_region | AWS region where resources will be created | `string` | `"us-east-1"`      | no |
| mysql_rds_cluster_identifier | MySQL RDS instance identifier to be monitored | `string` | `"guardium-mysql"` | no |
| mysql_major_version | Major version of MySQL (e.g., '5.7') | `string` | `"5.7"`            | no |
| audit_events | Comma-separated list of events to audit | `string` | `"CONNECT,QUERY"`  | no |
| audit_file_rotations | Number of audit file rotations to keep | `string` | `"10"`             | no |
| audit_file_rotate_size | Size in bytes before rotating audit file | `string` | `"1000000"`        | no |
| audit_incl_users | Comma-separated list of users to include in audit logs (SERVER_AUDIT_INCL_USERS). If set, only these users will be audited. Leave empty to audit all users. | `string` | `""`               | no |
| audit_excl_users | Comma-separated list of users to exclude from audit logs (SERVER_AUDIT_EXCL_USERS). The rdsadmin user queries the database every second for health checks, which can cause log files to grow quickly. | `string` | `"rdsadmin"`       | no |
| audit_query_log_limit | Maximum query length to log in bytes (SERVER_AUDIT_QUERY_LOG_LIMIT). Queries longer than this will be truncated. | `string` | `"1024"`           | no |
| udc_name | Name for universal connector (used for AWS objects) | `string` | `"mysql-gdp"`      | no |
| udc_aws_credential | Name of AWS credential defined in Guardium | `string` | n/a                | yes |
| gdp_client_id | Client ID used when running grdapi register_oauth_client | `string` | n/a                | yes |
| gdp_client_secret | Client secret from output of grdapi register_oauth_client | `string` | n/a                | yes |
| gdp_server | Hostname/IP address of Guardium Central Manager | `string` | n/a                | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"`           | no |
| gdp_username | Username of Guardium Web UI user | `string` | n/a                | yes |
| gdp_password | Password of Guardium Web UI user | `string` | n/a                | yes |
| gdp_ssh_username | Guardium OS user with SSH access | `string` | n/a                | yes |
| gdp_ssh_privatekeypath | Private SSH key to connect to Guardium OS | `string` | n/a                | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units to deploy profile | `string` | `""`               | no |
| log_export_type | Type of log export (Cloudwatch) | `string` | `"Cloudwatch"`     | no |
| force_failover | Whether to force failover during parameter group update | `bool` | `false`            | no |
| enable_universal_connector | Whether to enable the universal connector | `bool` | `true`             | no |
| csv_start_position | Start position for UDC | `string` | `"end"`            | no |
| csv_interval | Polling interval for UDC | `string` | `"5"`              | no |
| csv_event_filter | UDC Event filters | `string` | `""`               | no |
| tags | Map of tags to apply to resources | `map(string)` | `{}`               | no |

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

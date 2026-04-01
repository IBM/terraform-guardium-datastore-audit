# AWS OpenSearch with IBM Guardium Data Protection

This example demonstrates how to configure AWS OpenSearch with IBM Guardium Data Protection using audit logging for comprehensive monitoring.

## Architecture

```
┌───────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│                   │     │                   │     │                   │
│  AWS OpenSearch   │────►│  OpenSearch       │────►│  CloudWatch Logs  │
│  Domain           │     │  Audit Logging    │     │                   │
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

1. OpenSearch database activity is captured by OpenSearch audit logging
2. Audit logs are sent to CloudWatch Logs
3. Guardium Universal Connector reads from CloudWatch Logs
4. Guardium processes and analyzes the OpenSearch activity
5. Security teams can view and alert on OpenSearch activity in Guardium

## Overview

This Terraform configuration:

1. Configures an existing AWS OpenSearch domain for audit logging
2. Sets up a Universal Data Connector in Guardium to collect and analyze OpenSearch audit logs from CloudWatch
3. Enables comprehensive monitoring of database operations, user activity, and access patterns

## Prerequisites

Before using this example, ensure you have:

1. **AWS Resources**:
   - An existing AWS OpenSearch domain

2. **Guardium Data Protection**:
   - A running Guardium Data Protection instance (version 12.2.1 or above)
   - Completed the one-time manual configurations as described in [Preparing Guardium Documentation](https://github.com/IBM/terraform-guardium-gdp/blob/main/docs/preparing-guardium.md):
      - OAuth client registered via `grdapi register_oauth_client`
      - AWS credentials configured in Guardium Data Protection

## Usage

### 1. Create a terraform.tfvars File

Create a `terraform.tfvars` file with your configuration. See [terraform.tfvars.example](./terraform.tfvars.example) for an example with available options and detailed comments.

### 2. Initialize Terraform

  ```bash
  terraform init
  ```

### 3. Import the Existing OpenSearch Domain 

### You need to import existing OpenSearch domain before applying:

```bash
terraform import module.datastore-audit_amazon-opensearch-audit.aws_opensearch_domain.audit <YOUR-OPENSEARCH-DOMAIN>
```

Replace `<YOUR-OPENSEARCH-DOMAIN>` with the name of your existing OpenSearch domain.

**Note:** The module uses lifecycle rules to ignore most domain configuration changes, allowing you to safely import existing domains without forcing recreation. Only audit logging configuration and tags will be managed by Terraform.

### 4. Apply the Configuration

  ```bash
  terraform apply
  ```

Review the planned changes and type `yes` to apply them.

### 5. Verify the Configuration

After successful application:

1. Log in to your Guardium Data Protection web interface
2. Navigate to **Universal Connector** → **Datasource Profile Management**
3. Verify that the OpenSearch profile has been created and is active
4. Navigate to **CloudWatch** → **Log Groups** on the AWS UI and search for `/aws/OpenSearchService/<domain-name>/audit`. You should see log groups created
5. Navigate to the managed unit (collector) the UC is deployed on and ensure the STAP status is green/active

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region where resources will be created | `string` | `"us-east-1"` | no |
| opensearch_domain_name | OpenSearch domain name to be monitored | `string` | n/a | yes |
| enable_profiler_logs | Whether to enable profiler logs (INDEX_SLOW_LOGS) | `bool` | `false` | no |
| opensearch_master_username | Master username for OpenSearch domain | `string` | n/a | yes |
| opensearch_master_password | Master password for OpenSearch domain | `string` | n/a | yes |
| enable_security_plugin_auditing | Whether to enable security plugin auditing | `bool` | `true` | no |
| audit_rest_disabled_categories | List of REST audit categories to disable | `list(string)` | `[]` | no |
| audit_disabled_transport_categories | List of Transport audit categories to disable | `list(string)` | `[]` | no |
| udc_aws_credential | Name of AWS credential defined in Guardium | `string` | n/a | yes |
| gdp_client_id | Client ID used when running grdapi register_oauth_client | `string` | n/a | yes |
| gdp_client_secret | Client secret from output of grdapi register_oauth_client | `string` | n/a | yes |
| gdp_server | Hostname/IP address of Guardium Central Manager | `string` | n/a | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"` | no |
| gdp_username | Username of Guardium Web UI user | `string` | n/a | yes |
| gdp_password | Password of Guardium Web UI user | `string` | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units | `string` | n/a | yes |
| enable_universal_connector | Whether to enable the universal connector | `bool` | `true` | no |
| csv_start_position | Start position for UDC | `string` | `"end"` | no |
| csv_interval | Polling interval for UDC | `string` | `"5"` | no |
| csv_event_filter | UDC Event filters | `string` | `""` | no |
| use_aws_bundled_ca | Whether to use AWS bundled CA certificates | `bool` | `true` | no |
| log_group_prefix | Whether the log group name includes a prefix | `bool` | `false` | no |
| unmask | Whether to unmask sensitive data in audit logs | `bool` | `true` | no |
| tags | Map of tags to apply to resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cloudwatch_log_group_audit | Name of the CloudWatch Log Group for audit logs |
| cloudwatch_log_group_audit_arn | ARN of the CloudWatch Log Group for audit logs |
| cloudwatch_log_group_profiler | Name of the CloudWatch Log Group for profiler logs |
| cloudwatch_log_group_profiler_arn | ARN of the CloudWatch Log Group for profiler logs |
| aws_region | AWS region where resources are deployed |
| aws_account_id | AWS account ID |
| opensearch_domain_name | OpenSearch domain name |
| opensearch_domain_endpoint | OpenSearch domain endpoint |
| opensearch_domain_arn | OpenSearch domain ARN |
| opensearch_dashboard_url | OpenSearch Dashboard URL |

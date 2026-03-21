# AWS OpenSearch Audit Configuration

This module configures audit logging for AWS OpenSearch domains with IBM Guardium Data Protection. It enables OpenSearch audit logging via the native `aws_opensearch_domain` resource and configures log collection via CloudWatch.

**Supported Versions:** This module requires IBM Guardium Data Protection (GDP) version **12.2.1 and above**.

## Prerequisites

Before using this module, you need to:

1. Have an existing OpenSearch domain
2. Have Guardium set up with appropriate credentials
3. **Important**: Advanced security options must be enabled on your OpenSearch domain
4. **Important**: You must import the existing OpenSearch domain into Terraform state before applying this module

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | ~> 6.0 |
| guardium-data-protection | ~> 1.3 |
| gdp-middleware-helper | >= 1.0.0 |

## Features

- Configures existing OpenSearch domain for audit logging
- Enables audit log publishing to CloudWatch
- Optional profiler logs (INDEX_SLOW_LOGS) support
- Integrates with Guardium for audit data collection via CloudWatch

## Usage

### 1. Create a tfvars File

Create a `defaults.tfvars` file with your configuration. See [terraform.tfvars.example](./terraform.tfvars.example) for an example with available options and detailed comments.

### 2. Initialize Terraform

  ```bash
  terraform init
  ```

### 3. Import the Existing OpenSearch Domain

**IMPORTANT:** You must import your existing OpenSearch domain into Terraform state before applying:

  ```bash
  terraform import aws_opensearch_domain.audit <YOUR-OPENSEARCH-DOMAIN>
  ```
Replace `<YOUR-OPENSEARCH-DOMAIN>` with the name of your existing OpenSearch domain.

### 4. Apply the Configuration

  ```bash
  terraform apply
  ```

Review the planned changes and type `yes` to apply them.

## Provider Configuration

This module requires the AWS provider, Guardium Data Protection provider, and GDP middleware helper provider.
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

## OpenSearch Audit Logging

OpenSearch audit logging operates at two levels:

### 1. CloudWatch Audit Logs (AWS Level)
The module automatically enables audit log publishing to CloudWatch. 
When audit logging is enabled via the `aws_opensearch_domain` resource's `log_publishing_options`, logs are published to these pre-created log groups:

```
/aws/OpenSearchService/domains/<domain_name>/audit-logs
/aws/OpenSearchService/domains/<domain_name>/index-slow-logs (if profiler logs enabled)
```

### 2. Security Plugin Audit Logs (OpenSearch Level)
When `enable_security_plugin_auditing` is enabled, the module configures OpenSearch's built-in security plugin to capture detailed audit events.

### Configuring Audit Settings

The module uses best-practice audit settings with all audit features enabled by default. You can selectively disable specific audit categories if needed:

```hcl
module "opensearch_audit" {
  source = "./modules/amazon-opensearch-audit"
  
  # Enable security plugin auditing
  enable_security_plugin_auditing = true
  opensearch_master_username      = "admin"
  opensearch_master_password      = "YourSecurePassword123!"
  
  # Optional: Disable specific REST audit categories
  audit_rest_disabled_categories = ["GRANTED_PRIVILEGES", "AUTHENTICATED"]
  
  # Optional: Disable specific Transport audit categories
  audit_disabled_transport_categories = ["INDEX_EVENT"]
  
  # ... other required variables
}
```

#### Supported Audit Categories

For the complete list of supported audit categories and their descriptions, refer to the official AWS documentation:
[OpenSearch Audit Log Settings](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/audit-logs.html#audit-log-settings)

#### Default Audit Settings

| Setting | Value |
|---------|-------|
| `enable_rest` | `true` |
| `enable_transport` | `true` |
| `resolve_bulk_requests` | `true` |
| `log_request_body` | `true` |
| `resolve_indices` | `true` |
| `exclude_sensitive_headers` | `true` |
| `ignore_users` | `[]` |
| `ignore_requests` | `[]` |

#### Default Compliance Settings

| Setting | Value |
|---------|-------|
| `enabled` | `true` |
| `internal_config` | `true` |
| `external_config` | `false` |
| `read_metadata_only` | `true` |
| `read_ignore_users` | `[]` |
| `write_metadata_only` | `true` |
| `write_log_diffs` | `false` |
| `write_ignore_users` | `[]` |

**Note:** Only the disabled categories lists (`audit_rest_disabled_categories` and `audit_disabled_transport_categories`) are configurable through Terraform.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region | string | `"us-east-1"` | no |
| opensearch_domain_name | OpenSearch domain name to be monitored | string | n/a | yes |
| enable_profiler_logs | Enable profiler logs in addition to audit logs | bool | `false` | no |
| tags | Map of tags to apply to resources | map(string) | n/a | yes |
| enable_security_plugin_auditing | Enable OpenSearch security plugin auditing | bool | `true` | no |
| opensearch_master_username | OpenSearch master username for security plugin configuration | string | n/a | yes (if security plugin enabled) |
| opensearch_master_password | OpenSearch master password for security plugin configuration | string | n/a | yes (if security plugin enabled) |
| audit_rest_disabled_categories | List of REST audit categories to disable (all enabled by default) | list(string) | `[]` | no |
| audit_disabled_transport_categories | List of Transport audit categories to disable (all enabled by default) | list(string) | `[]` | no |
| udc_aws_credential | Name of AWS credential defined in Guardium | string | n/a | yes |
| gdp_client_secret | Client secret from Guardium | string | n/a | yes |
| gdp_client_id | Client ID from Guardium | string | n/a | yes |
| gdp_server | Guardium server hostname/IP | string | n/a | yes |
| gdp_port | Port of Guardium Central Manager | string | `"8443"` | no |
| gdp_username | Guardium username | string | n/a | yes |
| gdp_password | Guardium password | string | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units | string | n/a | yes |
| enable_universal_connector | Whether to enable the universal connector | bool | `true` | no |
| csv_start_position | Start position for UDC | string | `"end"` | no |
| csv_interval | Polling interval for UDC | string | `"5"` | no |
| csv_event_filter | UDC Event filters | string | `""` | no |
| use_aws_bundled_ca | Whether to use AWS bundled CA certificates | bool | `true` | no |
| log_group_prefix | Whether the log group name includes a prefix | bool | `false` | no |
| unmask | Whether to unmask sensitive data in audit logs | bool | `true` | no |


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

# AWS OpenSearch Audit Configuration

This module configures audit logging for AWS OpenSearch domains with IBM Guardium Data Protection. It enables OpenSearch audit logging and configures log collection via CloudWatch.

**Supported Versions:** This module requires IBM Guardium Data Protection (GDP) version **12.2.1 and above**.

## Prerequisites

Before using this module, you need to:

1. Have an existing OpenSearch domain
2. Have Guardium set up with appropriate credentials
3. Advanced security options must be enabled on your OpenSearch domain

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |
| guardium-data-protection | >= 1.0.0 |
| gdp-middleware-helper | >= 1.0.0 |

## Features

- Configures OpenSearch domain for audit logging
- Enables audit log publishing to CloudWatch
- Optional profiler logs (INDEX_SLOW_LOGS) support
- Integrates with Guardium for audit data collection via CloudWatch
- Automatic domain configuration management

## Usage

### Using a tfvars File

Create a `defaults.tfvars` file with your configuration. See [terraform.tfvars.example](./terraform.tfvars.example) for an example with available options and detailed comments.

Then run:

```bash
# Plan the changes
terraform plan -var-file=defaults.tfvars

# Apply the changes
terraform apply -var-file=defaults.tfvars
```

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

## OpenSearch Audit Logging

OpenSearch audit logging operates at two levels:

### 1. CloudWatch Audit Logs (AWS Level)
The module automatically enables audit log publishing to CloudWatch, which captures all OpenSearch API calls and security events.

### 2. Security Plugin Audit Logs (OpenSearch Level)
When `enable_security_plugin_auditing` is enabled, the module configures OpenSearch's built-in security plugin to capture detailed audit events.

#### Supported Audit Categories

**REST Layer:**
- FAILED_LOGIN
- MISSING_PRIVILEGES
- BAD_HEADERS
- SSL_EXCEPTION
- GRANTED_PRIVILEGES
- AUTHENTICATED

**Transport Layer:**
- OPENSEARCH_SECURITY_INDEX_ATTEMPT
- INDEX_EVENT
- COMPLIANCE_DOC_READ
- COMPLIANCE_DOC_WRITE
- COMPLIANCE_INTERNAL_CONFIG_READ
- COMPLIANCE_INTERNAL_CONFIG_WRITE

### Configuring Audit Settings

The module uses best-practice audit settings with all audit features enabled by default. You can selectively disable specific audit categories if needed:

```hcl
module "opensearch_audit" {
  source = "./modules/aws-opensearch-audit"
  
  # Enable security plugin auditing
  enable_security_plugin_auditing = true
  opensearch_master_username      = "admin"
  opensearch_master_password      = "YourSecurePassword123!"
  
  # Optional: Disable specific REST audit categories
  audit_rest_disabled_categories = ["GRANTED_PRIVILEGES", "AUTHENTICATED"]
  
  # Optional: Disable specific Transport audit categories
  audit_disabled_transport_categories = ["COMPLIANCE_DOC_READ"]
  
  # ... other required variables
}
```

**Hardcoded Best-Practice Settings:**
- `enable_rest`: true
- `enable_transport`: true
- `resolve_bulk_requests`: true
- `log_request_body`: true
- `resolve_indices`: true
- `exclude_sensitive_headers`: true

**Note:** Only the disabled categories lists are configurable. All other audit settings use secure defaults that follow OpenSearch security best practices.

### Filtering Events in Guardium

Use the `csv_event_filter` variable to control which events Guardium monitors from CloudWatch logs.

## CSV Profile Upload

The module uploads the Universal Connector CSV profile to Guardium via API:
- CSV file is created in your local workspace (`.terraform/` directory)
- Provider uploads file content directly via HTTP multipart/form-data
- No additional configuration required
- Secure and easy to use

## CloudWatch Integration

This module configures CloudWatch integration for OpenSearch auditing. The audit logs are automatically sent to CloudWatch log groups with the format:

```
/aws/OpenSearchService/<domain_name>/audit
/aws/OpenSearchService/<domain_name>/profiler (if enabled)
```

Guardium is configured to collect and analyze these logs through the Universal Connector.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region | string | `"us-east-1"` | no |
| opensearch_domain_name | OpenSearch domain name to be monitored | string | n/a | yes |
| enable_profiler_logs | Enable profiler logs in addition to audit logs | bool | `false` | no |
| log_retention_days | Number of days to retain CloudWatch logs | number | `7` | no |
| tags | Map of tags to apply to resources | map(string) | n/a | yes |
| **Security Plugin Auditing** | | | | |
| enable_security_plugin_auditing | Enable OpenSearch security plugin auditing | bool | `true` | no |
| opensearch_master_username | OpenSearch master username for security plugin configuration | string | n/a | yes (if security plugin enabled) |
| opensearch_master_password | OpenSearch master password for security plugin configuration | string | n/a | yes (if security plugin enabled) |
| audit_rest_disabled_categories | List of REST audit categories to disable (all enabled by default) | list(string) | `[]` | no |
| audit_disabled_transport_categories | List of Transport audit categories to disable (all enabled by default) | list(string) | `[]` | no |
| **Guardium Configuration** | | | | |
| udc_aws_credential | Name of AWS credential defined in Guardium | string | n/a | yes |
| gdp_client_secret | Client secret from Guardium | string | n/a | yes |
| gdp_client_id | Client ID from Guardium | string | n/a | yes |
| gdp_server | Guardium server hostname/IP | string | n/a | yes |
| gdp_port | Port of Guardium Central Manager | string | `"8443"` | no |
| gdp_username | Guardium username | string | n/a | yes |
| gdp_password | Guardium password | string | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units | string | n/a | yes |
| **Universal Connector Configuration** | | | | |
| enable_universal_connector | Whether to enable the universal connector | bool | `true` | no |
| csv_start_position | Start position for UDC | string | `"end"` | no |
| csv_interval | Polling interval for UDC | string | `"5"` | no |
| codec_pattern | Codec pattern for the Universal Connector | string | `""` | no |
| csv_event_filter | UDC Event filters | string | `""` | no |
| use_aws_bundled_ca | Whether to use AWS bundled CA certificates | bool | `true` | no |
| log_group_prefix | Prefix for log group names | string | `""` | no |
| unmask | Whether to unmask sensitive data | bool | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| profile_csv | Content of the profile CSV |
| udc_name | Name of the Universal Connector |
| cloudwatch_log_group_audit | Name of the CloudWatch Log Group for audit logs |
| cloudwatch_log_group_profiler | Name of the CloudWatch Log Group for profiler logs |
| aws_region | AWS region where resources are deployed |
| aws_account_id | AWS account ID |
| opensearch_domain_name | OpenSearch domain name |
| opensearch_domain_endpoint | OpenSearch domain endpoint |
| opensearch_domain_arn | OpenSearch domain ARN |
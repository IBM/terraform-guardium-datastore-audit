# Amazon OpenSearch Audit with IBM Guardium Data Protection (Kafka-based UC)

This example demonstrates how to configure an existing Amazon OpenSearch domain with IBM Guardium Data Protection using the unified `amazon-opensearch-audit` module in Kafka mode and Kafka-based Universal Connectors.

## Architecture

```text
┌──────────────────────┐     ┌──────────────────────┐     ┌──────────────────────┐
│                      │     │                      │     │                      │
│  Amazon OpenSearch   │────►│  CloudWatch Logs     │────►│  Guardium Kafka-     │
│  Domain              │     │  Audit Log Groups    │     │  based UC            │
│                      │     │                      │     │                      │
└──────────────────────┘     └──────────────────────┘     └──────────────────────┘
                                                                  │
                                                                  ▼
                                                         ┌──────────────────────┐
                                                         │                      │
                                                         │  Guardium Data       │
                                                         │  Protection          │
                                                         │                      │
                                                         └──────────────────────┘
```

## Data Flow

1. OpenSearch audit logging is enabled on an existing domain.
2. Audit logs are published to CloudWatch Logs.
3. Guardium Kafka-based Universal Connector reads the CloudWatch audit log stream.
4. Guardium processes and analyzes the OpenSearch audit activity.

## Overview

This Terraform example:

1. Configures an existing Amazon OpenSearch domain for audit logging.
2. Creates CloudWatch log groups and permissions required for OpenSearch log publishing.
3. Optionally enables OpenSearch security plugin auditing through the middleware helper provider.
4. Configures a Kafka-based Universal Connector in Guardium for audit log ingestion by setting `uc_mode = "kafka"` in the unified module.

## Prerequisites

Before using this example, ensure you have:

1. **AWS Resources**:
   - An existing Amazon OpenSearch domain
   - Advanced security enabled on the OpenSearch domain
   - AWS credentials configured for Terraform

2. **Guardium Data Protection**:
   - A running Guardium Data Protection instance (version 12.2.1 or above)
   - OAuth client registered via `grdapi register_oauth_client`
   - AWS credentials configured in Guardium
   - A Kafka cluster configured in Guardium
   - One or more Guardium Managed Units available for UC deployment

3. **Terraform State Preparation**:
   - The existing OpenSearch domain must be imported into Terraform state before apply

## Usage

### 1. Create a terraform.tfvars File

Create a `terraform.tfvars` file with your configuration. See [terraform.tfvars.example](./terraform.tfvars.example) for a complete example.

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Import the Existing OpenSearch Domain

You must import the existing OpenSearch domain before applying this example:

```bash
terraform import module.datastore-audit_amazon-opensearch-audit-kafka.aws_opensearch_domain.audit <YOUR-OPENSEARCH-DOMAIN>
```

Replace `<YOUR-OPENSEARCH-DOMAIN>` with the name of your existing OpenSearch domain.

### 4. Apply the Configuration

```bash
terraform apply
```

Review the planned changes and type `yes` to apply them.

### 5. Verify the Configuration

After successful application:

1. Verify the CloudWatch log group exists for:
   - `/aws/OpenSearchService/domains/<domain_name>/audit-logs`
   - `/aws/OpenSearchService/domains/<domain_name>/index-slow-logs` (if profiler logs are enabled)
2. Log in to Guardium Data Protection.
3. Navigate to **Universal Connector** → **Datasource Profile Management**.
4. Verify that the Kafka-based OpenSearch datasource profile has been created.
5. Confirm the profile is deployed to the expected managed units.

## Kafka-based UC Notes

This example uses Kafka-based Universal Connectors, which are intended for environments that require:

- Better scalability for high-volume audit streams
- Load balancing across multiple managed units
- Kafka cluster integration in Guardium
- Optional ELB support
- Configurable event delay and no-data thresholds

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region where resources are deployed | `string` | `"us-east-1"` | no |
| opensearch_domain_name | Name of the existing OpenSearch domain to be monitored | `string` | n/a | yes |
| enable_profiler_logs | Enable profiler logs in addition to audit logs | `bool` | `false` | no |
| enable_security_plugin_auditing | Enable OpenSearch security plugin auditing | `bool` | `true` | no |
| opensearch_master_username | OpenSearch master username | `string` | n/a | yes |
| opensearch_master_password | OpenSearch master password | `string` | n/a | yes |
| audit_rest_disabled_categories | REST audit categories to disable | `list(string)` | `[]` | no |
| audit_disabled_transport_categories | Transport audit categories to disable | `list(string)` | `[]` | no |
| udc_aws_credential | Name of AWS credential defined in Guardium | `string` | n/a | yes |
| gdp_client_id | Guardium OAuth client ID | `string` | n/a | yes |
| gdp_client_secret | Guardium OAuth client secret | `string` | n/a | yes |
| gdp_server | Guardium Central Manager hostname/IP | `string` | n/a | yes |
| gdp_port | Guardium Central Manager port | `string` | `"8443"` | no |
| gdp_username | Guardium Web UI username | `string` | n/a | yes |
| gdp_password | Guardium Web UI password | `string` | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units | `string` | n/a | yes |
| enable_universal_connector | Whether to enable the universal connector | `bool` | `true` | no |
| udc_description | Description for the Universal Connector | `string` | `""` | no |
| kafka_cluster_name | Kafka cluster name configured in Guardium | `string` | `"kafka"` | no |
| use_elb | Whether to use ELB for Kafka-based UC | `bool` | `false` | no |
| mu_count | Number of managed units for Kafka-based UC | `number` | `2` | no |
| event_delay | Event delay in seconds for Kafka-based UC | `number` | `15` | no |
| nodata_threshold_min | No data threshold in minutes for Kafka-based UC | `number` | `60` | no |
| unmask | Whether to unmask sensitive data in audit logs | `bool` | `false` | no |
| filter_pattern | CloudWatch Logs filter pattern for filtering audit logs | `string` | `"None"` | no |
| tags | Map of tags to apply to resources | `map(string)` | `{}` | no |

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
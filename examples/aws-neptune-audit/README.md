# AWS Neptune with IBM Guardium Data Protection

This example demonstrates how to configure AWS Neptune with IBM Guardium Data Protection using audit logging for comprehensive monitoring.

## Architecture

```
┌───────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│                   │     │                   │     │                   │
│  AWS Neptune      │────►│  Neptune Audit    │────►│  CloudWatch Logs  │
│  Cluster          │     │  Logging          │     │                   │
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

1. Neptune database activity is captured by Neptune audit logging
2. Audit logs are sent to CloudWatch Logs
3. Guardium Universal Connector reads from CloudWatch Logs
4. Guardium processes and analyzes the Neptune activity
5. Security teams can view and alert on Neptune activity in Guardium

## Overview

This Terraform configuration:

1. Configures an existing AWS Neptune cluster for audit logging
2. Sets up a Universal Data Connector in Guardium to collect and analyze Neptune audit logs from CloudWatch
3. Enables comprehensive monitoring of database operations, user activity, and access patterns

## Prerequisites

Before using this example, ensure you have:

1. **AWS Resources**:
   - An existing AWS Neptune cluster

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

### 3. Import the Neptune Parameter Group (if using custom parameter group)

Identify existing parameter group name:

  ```bash
  # Get current parameter group name
  aws neptune describe-db-clusters \
    --db-cluster-identifier your-neptune-cluster \
    --region your-region \
    --query "DBClusters[0].DBClusterParameterGroup" \
    --output text
  ```

Import existing parameter group (only if it's a custom parameter group):
   ```bash
   terraform import module.datastore-audit_aws-neptune-audit.aws_neptune_cluster_parameter_group.guardium <your-parameter-group-name>
   ```

**Note**: Skipping the import step for custom parameter groups will cause Terraform to attempt creating a new parameter group, which may fail or cause unexpected behavior.

### 4. Apply the Configuration

  ```bash
  terraform apply
  ```

Review the planned changes and type `yes` to apply them.

### 5. Verify the Configuration

After successful application:

1. Log in to your Guardium Data Protection web interface
2. Navigate to **Universal Connector** → **Datasource Profile Management**
3. Verify that the Neptune profile has been created and is active
4. Navigate to **CloudWatch** → **Log Groups** on the AWS UI and search for `/aws/neptune/<neptune_cluster_id>/audit`. You should see log groups created
5. Navigate to the managed unit (collector) the UC is deployed on and ensure the STAP status is green/active

## CloudWatch Integration

The module configures Neptune to send audit logs to CloudWatch Logs. The Universal Connector then:

1. Reads these logs from CloudWatch using the configured AWS credentials
2. Parses and normalizes the log data
3. Forwards the processed audit events to Guardium for analysis

## Neptune Audit Logging

Neptune audit logging captures:
- **Gremlin queries**: Apache TinkerPop Gremlin graph traversal queries
- **SPARQL queries**: W3C SPARQL queries for RDF data
- Connection events and authentication attempts

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region where resources will be created | `string` | `"us-east-1"` | no |
| neptune_cluster_identifier | Neptune cluster identifier to be monitored | `string` | `"guardium-neptune"` | no |
| neptune_endpoint | Neptune cluster endpoint (optional - will be fetched automatically if not provided) | `string` | `""` | no |
| udc_aws_credential | Name of AWS credential defined in Guardium | `string` | n/a | yes |
| gdp_client_id | Client ID used when running grdapi register_oauth_client | `string` | n/a | yes |
| gdp_client_secret | Client secret from output of grdapi register_oauth_client | `string` | n/a | yes |
| gdp_server | Hostname/IP address of Guardium Central Manager | `string` | n/a | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"` | no |
| gdp_username | Username of Guardium Web UI user | `string` | n/a | yes |
| gdp_password | Password of Guardium Web UI user | `string` | n/a | yes |
| gdp_mu_host | Comma separated list of Guardium Managed Units to deploy profile | `string` | `""` | no |
| enable_universal_connector | Whether to enable the universal connector | `bool` | `true` | no |
| csv_start_position | Start position for UDC | `string` | `"end"` | no |
| csv_interval | Polling interval for UDC | `string` | `"5"` | no |
| codec_pattern | Codec pattern for the Universal Connector | `string` | `""` | no |
| csv_event_filter | UDC Event filters | `string` | `""` | no |
| use_aws_bundled_ca | Whether to use the AWS bundled CA certificates for Neptune connection | `bool` | `true` | no |
| tags | Map of tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| udc_name | Name of the Universal Connector |
| parameter_group_name | Name of the Neptune cluster parameter group |
| cloudwatch_log_group | CloudWatch Log Group for audit logs |
| aws_region | AWS region where resources are deployed |
| aws_account_id | AWS account ID |
| neptune_cluster_identifier | Neptune cluster identifier |
| neptune_cluster_endpoint | Neptune cluster endpoint |

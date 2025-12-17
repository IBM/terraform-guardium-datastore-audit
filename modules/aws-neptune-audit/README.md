# AWS Neptune Audit Configuration

This module configures audit logging for AWS Neptune clusters with IBM Guardium Data Protection. It enables Neptune audit logging through cluster parameter groups and configures log collection via CloudWatch.

**Supported Versions:** This module requires IBM Guardium Data Protection (GDP) version **12.2.1 and above**.

## Prerequisites

Before using this module, you need to:

1. Have an existing Neptune cluster
2. Have Guardium set up with appropriate credentials
3. **Important**: You must initialize Terraform and import the existing parameter group before applying this module (if using a custom parameter group)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |
| guardium-data-protection | >= 1.0.0 |

### Parameter Group Import Process

This module automatically detects whether your Neptune cluster uses a default or custom parameter group:

- **Default Parameter Group**: If your cluster uses the default parameter group (e.g., `default.neptune1`), the module creates a new custom parameter group
- **Custom Parameter Group**: If your cluster already uses a custom parameter group, the module modifies it to enable audit logging

To ensure Terraform manages your Neptune cluster correctly when using a custom parameter group:

1. Initialize Terraform in your working directory:
   ```bash
   terraform init
   ```
   
2. Identify your current parameter group:
   ```bash
   aws neptune describe-db-clusters \
   --db-cluster-identifier your-neptune-cluster \
   --region your-region \
   --query "DBClusters[0].DBClusterParameterGroup" \
   --output text
   ```

3. Import your current parameter group (only if it's a custom parameter group):
   ```bash
   terraform import module.datastore-audit_aws-neptune-audit.aws_neptune_cluster_parameter_group.guardium <your-parameter-group-name>
   ```

**Note**: Skipping the import step for custom parameter groups will cause Terraform to attempt creating a new parameter group, which may fail or cause unexpected behavior.

## Features

- Configures Neptune cluster for audit logging
- Enables `neptune_enable_audit_log` parameter
- Supports both Gremlin and SPARQL query logging
- Integrates with Guardium for audit data collection via CloudWatch
- Automatic parameter group detection and management

## Usage

### Using a tfvars File

Create a `defaults.tfvars` file with your configuration. See [terraform.tfvars.example](./terraform.tfvars.example) for an example with available options and detailed comments.

Then run:

```bash
# Import existing resources (if using custom parameter group)
# See the "Parameter Group Import Process" section above

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

## Neptune Audit Logging

Neptune audit logging captures:
- **Gremlin queries**: Apache TinkerPop Gremlin graph traversal queries
- **SPARQL queries**: W3C SPARQL queries for RDF data
- Connection events and authentication attempts

## CSV Profile Upload

The module uploads the Universal Connector CSV profile to Guardium via API:
- CSV file is created in your local workspace (`.terraform/` directory)
- Provider uploads file content directly via HTTP multipart/form-data
- No additional configuration required
- Secure and easy to use
- Works seamlessly when using modules from remote sources (Git/Terraform Registry)

## CloudWatch Integration

This module configures CloudWatch integration for Neptune auditing. The audit logs are automatically sent to a CloudWatch log group with the format:

```
/aws/neptune/<neptune_cluster_identifier>/audit
```

Guardium is configured to collect and analyze these logs through the Universal Connector.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region | string | `"us-east-1"` | no |
| neptune_cluster_identifier | Neptune cluster identifier to be monitored | string | n/a | yes |
| tags | Map of tags to apply to resources | map(string) | n/a | yes |
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
| codec_pattern | Codec pattern for the Universal Connector | string | `""` | no |
| csv_event_filter | UDC Event filters | string | `""` | no |
| neptune_endpoint | Neptune cluster endpoint (optional - will be fetched automatically if not provided) | string | `""` | no |
| use_aws_bundled_ca | Whether to use the AWS bundled CA certificates for Neptune connection | bool | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| udc_name | Name of the Universal Connector |
| cloudwatch_log_group | Name of the CloudWatch Log Group for audit logs |
| parameter_group_name | Name of the Neptune cluster parameter group |
| aws_region | AWS region where resources are deployed |
| aws_account_id | AWS account ID |
| neptune_cluster_identifier | Neptune cluster identifier |
| neptune_cluster_endpoint | Neptune cluster endpoint |

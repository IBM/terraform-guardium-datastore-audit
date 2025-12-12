# AWS DocumentDB Audit Configuration Module

This Terraform module enables comprehensive monitoring and auditing of AWS DocumentDB clusters using IBM Guardium Data Protection. It automates the configuration of DocumentDB audit logging and sets up a Universal Data Connector to stream audit logs to Guardium for analysis.

## Overview

The module performs two key functions:

1. **DocumentDB Configuration**: Creates or modifies a DocumentDB parameter group to enable audit logging and profiling
2. **Guardium Integration**: Sets up a Universal Data Connector to collect and analyze DocumentDB audit logs from CloudWatch

## Prerequisites

- An existing AWS DocumentDB cluster
- Guardium Data Protection instance with:
  - SSH access for file transfers (required only for GDP < 12.2.1)
  - Web UI credentials with appropriate permissions
  - OAuth client registered via `grdapi register_oauth_client`
  - AWS credentials configured in Guardium for CloudWatch access

## Guardium Data Protection Version Compatibility

**Important:** The upload method for Universal Connector profiles depends on your Guardium Data Protection (GDP) version:

- **GDP 12.2.1 and above**: Use API-based upload by setting `use_multipart_upload = true` (default and recommended)
- **GDP versions below 12.2.1**: Use SFTP-based upload by setting `use_multipart_upload = false`

When using SFTP (`use_multipart_upload = false`), you must also provide `gdp_ssh_username` and `gdp_ssh_privatekeypath` for authentication.

## Usage

**For GDP 12.2.1 and above (API upload - recommended):**
```hcl
module "datastore-audit_aws-documentdb" {
  source = "IBM/datastore-audit/guardium//modules/aws-documentdb"

  # AWS DocumentDB details
  documentdb_cluster_identifier = "my-docdb-cluster"
  aws_region                    = "us-east-1"
  
  # Guardium connection details
  gdp_server             = "guardium.example.com"
  gdp_port               = "8443"
  gdp_username           = "guardium-user"
  gdp_password           = "guardium-password"
  
  # Guardium OAuth details
  gdp_client_id          = "client1"
  gdp_client_secret      = "client-secret-value"
  
  # Universal Connector configuration
  udc_name               = "docdb-connector"
  udc_aws_credential     = "aws-credential-name"
  gdp_mu_host            = "mu1,mu2"
  
  # API upload (default for GDP 12.2.1+)
  use_multipart_upload = true
  
  # Optional: Tags
  tags = {
    Environment = "Production"
    Owner       = "Security Team"
  }
}
```

**For GDP versions below 12.2.1 (SFTP upload):**
```hcl
module "datastore-audit_aws-documentdb" {
  source = "IBM/datastore-audit/guardium//modules/aws-documentdb"

  # AWS DocumentDB details
  documentdb_cluster_identifier = "my-docdb-cluster"
  aws_region                    = "us-east-1"
  
  # Guardium connection details
  gdp_server             = "guardium.example.com"
  gdp_port               = "8443"
  gdp_username           = "guardium-user"
  gdp_password           = "guardium-password"
  gdp_ssh_username       = "guardium-ssh-user"
  gdp_ssh_privatekeypath = "/path/to/private/key"
  
  # Guardium OAuth details
  gdp_client_id          = "client1"
  gdp_client_secret      = "client-secret-value"
  
  # Universal Connector configuration
  udc_name               = "docdb-connector"
  udc_aws_credential     = "aws-credential-name"
  gdp_mu_host            = "mu1,mu2"
  
  # SFTP upload for GDP < 12.2.1
  use_multipart_upload   = false
  
  # Optional: Tags
  tags = {
    Environment = "Production"
    Owner       = "Security Team"
  }
}
```

## Parameter Group Management

The module intelligently handles DocumentDB parameter groups:

- If the cluster uses a default parameter group, it creates a new custom parameter group
- If the cluster already uses a custom parameter group, it modifies that group
- Parameter changes include enabling audit logs and profiler with appropriate settings

### Importing Existing Parameter Groups

If you're using a custom parameter group that was created outside of Terraform:

```bash
terraform import -var="enable_universal_connector=false" \
  -var-file=defaults.tfvars \
  aws_docdb_cluster_parameter_group.guardium your-parameter-group-name
```

## CloudWatch Integration

The module configures DocumentDB to send audit logs to CloudWatch Logs. The Universal Connector then:

1. Reads these logs from CloudWatch using the configured AWS credentials
2. Parses and normalizes the log data
3. Forwards the processed audit events to Guardium for analysis

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region where resources will be created | `string` | `"us-east-1"` | no |
| documentdb_cluster_identifier | DocumentDB cluster identifier to be monitored | `string` | `"guardium-docdb"` | no |
| udc_name | Name for universal connector (used for AWS objects) | `string` | `"documentdb-gdp"` | no |
| udc_aws_credential | Name of AWS credential defined in Guardium | `string` | n/a | yes |
| gdp_client_id | Client ID used when running grdapi register_oauth_client | `string` | n/a | yes |
| gdp_client_secret | Client secret from output of grdapi register_oauth_client | `string` | n/a | yes |
| gdp_server | Hostname/IP address of Guardium Central Manager | `string` | n/a | yes |
| gdp_port | Port of Guardium Central Manager | `string` | `"8443"` | no |
| gdp_username | Username of Guardium Web UI user | `string` | n/a | yes |
| gdp_password | Password of Guardium Web UI user | `string` | n/a | yes |
| gdp_ssh_username | Guardium OS user with SSH access (required when use_multipart_upload = false) | `string` | n/a | conditional |
| gdp_ssh_privatekeypath | Private SSH key to connect to Guardium OS (required when use_multipart_upload = false) | `string` | n/a | conditional |
| gdp_mu_host | Comma separated list of Guardium Managed Units to deploy profile | `string` | `""` | no |
| use_multipart_upload | Use API upload (true, for GDP 12.2.1+) or SFTP (false, for GDP < 12.2.1) | `bool` | `true` | no |
| enable_universal_connector | Whether to enable the universal connector module | `bool` | `true` | no |
| create_parameter_group | Whether to create a new parameter group | `bool` | `false` | no |
| csv_start_position | Starting position for log reading (START_OF_FILE or END_OF_FILE) | `string` | `"END_OF_FILE"` | no |
| csv_interval | Interval in seconds for checking new logs | `string` | `"60"` | no |
| csv_event_filter | Filter expression for log events | `string` | `""` | no |
| codec_pattern | Codec pattern for DocumentDB CloudWatch logs | `string` | `"plain"` | no |
| cloudwatch_endpoint | Custom endpoint URL for AWS CloudWatch. Leave empty to use default AWS endpoint | `string` | `""` | no |
| use_aws_bundled_ca | Whether to use the AWS bundled CA certificates for CloudWatch connection | `bool` | `true` | no |
| use_multipart_upload | Whether to use multipart upload for CSV files (true) or SFTP (false). Multipart upload is recommended as it doesn't require SFTP access. | `bool` | `true` | no |
| profile_upload_directory | Directory path for SFTP upload (chroot path for CLI user) | `string` | `"/upload"` | no |
| profile_api_directory | Full filesystem path for Guardium API to read CSV files | `string` | `"/var/IBM/Guardium/file-server/upload"` | no |
| tags | Map of tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| profile_csv | The CSV profile configuration for the Universal Connector |

## Implementation Details

### DocumentDB Parameter Configuration

The module configures the following parameters in DocumentDB:

- `audit_logs`: Enabled to capture database activity
- `profiler`: Enabled to capture query performance data
- `profiler_threshold_ms`: Set to 50ms to capture queries exceeding this duration

### Universal Connector Setup

The module uses the `universal-connector/install-gdp-connector` submodule to:

1. Generate a CSV profile configuration using the DocumentDB CloudWatch template
2. Copy the profile to the Guardium server via SSH
3. Import the profile into Guardium using the API
4. Deploy the connector to specified Managed Units

### CloudWatch Log Groups

The module configures the connector to monitor two CloudWatch Log groups:
- `/aws/docdb/{cluster-name}/audit`
- `/aws/docdb/{cluster-name}/profiler`

## Notes and Limitations

- Parameter group changes may require a cluster reboot to take effect
- The module requires appropriate AWS IAM permissions for CloudWatch Logs access
- For high-volume DocumentDB clusters, consider adjusting the `csv_interval` parameter
- The connector uses the AWS SDK to access CloudWatch Logs, so ensure network connectivity

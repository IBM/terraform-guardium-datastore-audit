# Guardium Data Protection Universal Connector Module

This Terraform module installs and configures a Universal Data Connector (UDC) in IBM Guardium Data Protection (GDP). The module handles authentication, profile import, and connector installation.

## Overview

The Universal Data Connector module provides a standardized way to:

1. Copy a CSV profile configuration to the Guardium server
2. Authenticate with the Guardium API
3. Import the connector profile into Guardium
4. Install the connector on specified Managed Units

This module is designed to be used as a submodule by other datastore-specific modules, such as the AWS DocumentDB audit configuration module.

## Usage

```hcl
module "universal_connector" {
  source = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  
  udc_name              = "my-connector-name"
  udc_csv_parsed        = local.connector_csv_content
  
  # Guardium authentication details
  client_id              = var.gdp_client_id
  client_secret          = var.gdp_client_secret
  gdp_server             = var.gdp_server
  gdp_port               = var.gdp_port
  gdp_username           = var.gdp_username
  gdp_password           = var.gdp_password
  
  # SSH access for file transfer
  gdp_ssh_username       = var.gdp_ssh_username
  gdp_ssh_privatekeypath = var.gdp_ssh_privatekeypath
  
  # Deployment target
  gdp_mu_host            = var.gdp_mu_host
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| udc_csv_parsed | The parsed CSV profile content for the connector | `string` | n/a | yes |
| udc_name | Universal Data Collector name (unique identifier in the UI) | `string` | `""` | yes |
| client_id | The client ID used to create the GDP OAuth client secret | `string` | n/a | yes |
| client_secret | The client secret from `grdapi register_oauth_client` | `string` | n/a | yes |
| gdp_server | Hostname or IP address of the Guardium server | `string` | n/a | yes |
| gdp_port | Port for the Guardium server | `string` | `"8443"` | no |
| gdp_username | Username for Guardium authentication | `string` | n/a | yes |
| gdp_password | Password for Guardium authentication | `string` | n/a | yes |
| gdp_ssh_username | SSH username for Guardium server access | `string` | n/a | yes |
| gdp_ssh_privatekeypath | Path to SSH private key for Guardium server access | `string` | n/a | yes |
| gdp_mu_host | Comma-separated list of Guardium Managed Units to deploy the profile | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| profile_csv | The CSV profile content used for the connector |

## How It Works

1. The module uses the `terraform_data` resource to copy the CSV profile to the Guardium server via SSH
2. It authenticates with the Guardium API using the provided credentials
3. It imports the connector profile using the `guardium-data-protection_import_profiles` resource
4. It installs the connector on the specified Managed Units using the `guardium-data-protection_install_connector` resource

## Example: AWS DocumentDB Integration

This module is used by the AWS DocumentDB audit configuration module to create a connector that reads DocumentDB audit logs from CloudWatch:

```hcl
module "universal_connector" {
  source = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  count  = var.enable_universal_connector ? 1 : 0
  
  udc_name = local.udc_name
  udc_csv_parsed = templatefile("${path.module}/templates/documentdbCloudwatch.tpl", {
    udc_name        = local.udc_name
    credential_name = var.udc_aws_credential
    aws_region      = var.aws_region
    aws_account_id  = local.aws_account_id
    aws_log_group   = format("/aws/docdb/%s/audit,/aws/docdb/%s/profiler", 
                            var.documentdb_cluster_identifier, 
                            var.documentdb_cluster_identifier)
    start_position  = var.csv_start_position
    interval        = var.csv_interval
    event_filter    = var.csv_event_filter
    description     = "GDP AWS DocumentDB connector for ${var.documentdb_cluster_identifier}"
    cluster_name    = var.documentdb_cluster_identifier
  })
  
  # Guardium connection details
  client_id              = var.gdp_client_id
  client_secret          = var.gdp_client_secret
  gdp_server             = var.gdp_server
  gdp_port               = var.gdp_port
  gdp_username           = var.gdp_username
  gdp_password           = var.gdp_password
  gdp_ssh_username       = var.gdp_ssh_username
  gdp_ssh_privatekeypath = var.gdp_ssh_privatekeypath
  gdp_mu_host            = var.gdp_mu_host
}
```

## Requirements

- Terraform >= 0.13.0
- SSH access to the Guardium server
- Valid Guardium API credentials
- Appropriate permissions to install connectors on the Guardium system

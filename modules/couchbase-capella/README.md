# Couchbase Capella Audit Configuration Module

This module enables audit logging on an **existing** Couchbase Capella cluster and integrates it with IBM Guardium Data Protection via Universal Connector.

## Overview

This module:
- ✅ Enables audit logging on your existing Capella cluster
- ✅ Configures which events to audit
- ✅ Sets up Guardium Universal Connector to read audit logs via REST API
- ✅ Streams audit data to Guardium Data Protection for monitoring

## Prerequisites

Before using this module, ensure you have:

1. **Existing Capella Cluster**: A running Couchbase Capella cluster
2. **Capella API Token**: With permissions to configure audit settings
3. **Guardium Data Protection**: Version 12.2.1 or above
4. **Guardium OAuth Client**: Registered via `grdapi register_oauth_client`
5. **Capella Credentials in Guardium**: API credentials configured in Guardium Central Manager

## Cluster Information You Need

Gather these details from your Capella console:

```
Organization ID: Found in Settings → Organization
Project ID:      The project containing your cluster
Cluster ID:      Your cluster's unique identifier
Cluster Name:    The name of your cluster
API Token:       Your Capella API token with audit permissions
```

### How to Find These:

1. Log into https://cloud.couchbase.com
2. Navigate to your cluster
3. Click on cluster details
4. Copy the IDs from the URL or settings page

## Usage

### Basic Example

```hcl
module "capella_audit" {
  source = "IBM/datastore-audit/guardium//modules/couchbase-capella"

  # Your Existing Capella Cluster
  capella_organization_id = "your-org-id-here"
  capella_project_id      = "your-project-id-here"
  capella_cluster_id      = "your-cluster-id-here"

  # Capella API Token
  capella_api_token = var.capella_api_token

  # Audit Log Settings (example)
  auditlogsettings = {
    audit_enabled     = true
    enabled_event_ids = [20485, 28672, 28675, 28676, 28678, 28679, 28682, 28686, 28687, 45074]
    disabled_users    = []
  }

  # Guardium Configuration
  gdp_server        = "guardium.example.com"
  gdp_port          = "8443"
  gdp_username      = "admin"
  gdp_password      = "your-password"
  gdp_client_id     = "client4"
  gdp_client_secret = "your-client-secret"
  gdp_mu_host       = "guardium-mu.example.com"

  # Universal Connector Configuration
  enable_universal_connector = true
  csv_query_interval        = "3600"  # Query interval in seconds
  csv_query_length          = "3600"  # Query length in seconds
  csv_description           = "Guardium connector for Capella cluster"
}
```

### Advanced Configuration

```hcl
module "capella_audit" {
  source = "IBM/datastore-audit/guardium//modules/couchbase-capella"

  # Capella Cluster
  capella_organization_id = "org-123"
  capella_project_id      = "proj-456"
  capella_cluster_id      = "cluster-789"
  capella_api_token       = var.capella_api_token

  # Audit Log Settings (example)
  auditlogsettings = {
    audit_enabled     = true
    enabled_event_ids = [20485, 28672, 28675, 28676, 28678, 28679, 28682, 28686, 28687, 45074]
    disabled_users = [
      {
        name   = "internal_monitor"
        domain = "local"
      },
      {
        name   = "backup_user"
        domain = "local"
      }
    ]
  }

  # Guardium
  gdp_server        = "guardium.example.com"
  gdp_username      = "admin"
  gdp_password      = var.gdp_password
  gdp_client_id     = "client4"
  gdp_client_secret = var.gdp_client_secret
  gdp_mu_host       = "mu1.example.com,mu2.example.com"

  # Universal Connector Configuration
  enable_universal_connector = true
  csv_query_interval        = "3600"  # Poll every 60 minutes (3600 seconds)
  csv_query_length          = "3600"  # Query length in seconds
  csv_description           = "Production Capella Audit"
}
```

## Configuration Steps

### Step 1: Configure Variables

Create a `terraform.tfvars` file:

```hcl
# Capella Cluster (existing)
capella_organization_id = "your-org-id"
capella_project_id      = "your-project-id"
capella_cluster_id      = "your-cluster-id"
capella_api_token       = "your-capella-api-token"

# Audit Log Settings
auditlogsettings = {
  audit_enabled     = true
  enabled_event_ids = [20485, 28672, 28675, 28676, 28678, 28679, 28682, 28686, 28687, 45074]
  disabled_users    = []
}

# Guardium
gdp_server        = "guardium.example.com"
gdp_username      = "admin"
gdp_password      = "secure-password"
gdp_client_id     = "client4"
gdp_client_secret = "oauth-secret"
gdp_mu_host       = "guardium-mu.example.com"

# Universal Connector
enable_universal_connector = true
csv_query_interval        = "3600"
csv_query_length          = "3600"
csv_description           = "Guardium connector for Capella"
```

### Step 2: Run Terraform

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply configuration
terraform apply
```

## What Gets Configured

When you run this module:

```
┌─────────────────────────────────────────┐
│  Your Existing Capella Cluster          │
│  (No changes to cluster itself)         │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Enable Audit Logging                   │
│  ✓ Authentication events                │
│  ✓ Authorization events                 │
│  ✓ Data access events                   │
│  ✓ Admin operations                     │
│  ✓ Query operations                     │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Configure Universal Connector          │
│  ✓ REST API endpoint to Capella         │
│  ✓ Polling interval (5 minutes)         │
│  ✓ Event filtering                      │
│  ✓ Credential mapping                   │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Stream to Guardium Data Protection     │
│  ✓ Real-time monitoring                 │
│  ✓ Security analysis                    │
│  ✓ Compliance reporting                 │
└─────────────────────────────────────────┘
```

## Variables Reference

### Required Variables

| Variable | Description |
|----------|-------------|
| `capella_organization_id` | Your Capella organization ID |
| `capella_project_id` | Project ID containing the cluster |
| `capella_cluster_id` | Cluster ID to enable auditing on |
| `capella_api_token` | Capella API token for authentication |
| `auditlogsettings` | Audit log configuration object |
| `gdp_server` | Guardium server hostname |
| `gdp_username` | Guardium username |
| `gdp_password` | Guardium password |
| `gdp_client_secret` | OAuth client secret |

| Variable | Default | Description |
|----------|---------|-------------|
| `capella_api_host` | `"https://cloudapi.cloud.couchbase.com"` | Capella API endpoint |
| `gdp_port` | `"8443"` | Guardium server port |
| `gdp_client_id` | `"client4"` | OAuth client ID |
| `gdp_mu_host` | `""` | Comma-separated list of Guardium Managed Units |
| `enable_universal_connector` | `true` | Enable Universal Connector integration |
| `csv_query_interval` | `"3600"` | Query interval in seconds |
| `csv_query_length` | `"3600"` | Query length in seconds |
| `csv_description` | `""` | Description for the UDC connector |

See `variables.tf` for complete list.

## Outputs

This module provides outputs for verification:

```hcl
output "udc_name" {
  description = "Universal Connector name"
}

output "cluster_id" {
  description = "Capella cluster ID"
}

output "audit_enabled" {
  description = "Whether audit logging is enabled"
}
```

## Troubleshooting

### Audit Logs Not Appearing in Guardium

1. **Check Capella API Token**: Ensure token has audit permissions
2. **Check Network Connectivity**: Guardium must reach Capella API
3. **Review UC Logs**: Check Universal Connector logs in Guardium
4. **Verify Polling Interval**: Default is 3600 seconds (1 hour)

### Authentication Errors

```
Error: Failed to enable audit logging
```

**Solution**: Verify `capella_api_token` is valid and has correct permissions

### Universal Connector Not Polling

1. Check `csv_query_interval` setting (in seconds)
2. Verify Guardium can reach `cloudapi.cloud.couchbase.com`
3. Review UC status in Guardium console
4. Check that `enable_universal_connector = true`

### Configuration Changes Not Applied

When you change `csv_query_interval`, `csv_query_length`, or other CSV parameters, you may need to force recreation of the Guardium resources:

```bash
terraform taint 'module.capella_audit.module.gdp_connect-datasource-to-uc[0].guardium-data-protection_import_profiles.import_profiles'
terraform taint 'module.capella_audit.module.gdp_connect-datasource-to-uc[0].guardium-data-protection_install_connector.install_connector'
terraform apply
```

## Important Notes

1. **No Cluster Changes**: This module only enables audit logging, it doesn't modify your cluster
2. **API Rate Limits**: Capella API has rate limits; adjust `csv_interval` if needed
3. **Audit Log Retention**: Capella retains audit logs for a limited time
4. **Costs**: Audit logging may incur additional Capella costs
5. **Security**: Store API tokens and passwords securely

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                 Couchbase Capella                        │
│  ┌────────────────────────────────────────────────┐      │
│  │  Your Existing Cluster                         │      │
│  │  • Buckets                                     │      │
│  │  • Data                                        │      │
│  │  • Applications                                │      │
│  └────────────────────────────────────────────────┘      │
│                        ↓                                 │
│  ┌────────────────────────────────────────────────┐      │
│  │  Audit Logging (Enabled by this module)       │      │
│  │  • Authentication events                       │      │
│  │  • Data access events                          │      │
│  │  • Admin operations                            │      │
│  └────────────────────────────────────────────────┘      │
└──────────────────────────────────────────────────────────┘
                        ↓ REST API
┌──────────────────────────────────────────────────────────┐
│         Guardium Universal Connector                     │
│  • Polls Capella API every 5 minutes                     │
│  • Reads audit logs via REST                             │
│  • Parses and normalizes events                          │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│         Guardium Data Protection                         │
│  • Security monitoring                                   │
│  • Threat detection                                      │
│  • Compliance reporting                                  │
│  • Forensic analysis                                     │
└──────────────────────────────────────────────────────────┘
```

## Next Steps

After enabling audit logging:

1. **Verify in Capella Console**: Check that audit logging is enabled
2. **Monitor in Guardium**: View audit events in Guardium dashboard
3. **Configure Policies**: Set up security policies in Guardium
4. **Set Up Alerts**: Configure alerts for suspicious activity

## License

Apache 2.0 - See LICENSE file for details
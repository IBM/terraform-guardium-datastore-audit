# Couchbase Capella Audit Configuration Example

This example demonstrates how to enable audit logging on an **existing** Couchbase Capella cluster and integrate it with IBM Guardium Data Protection.

## What This Example Does

```
Your Existing Capella Cluster
         ↓
    Enable Audit Logging
         ↓
    Configure Guardium Universal Connector
         ↓
    Stream Audit Logs to Guardium
```

## Prerequisites

Before running this example:

1. ✅ **Existing Capella Cluster**: You must have a running Capella cluster
2. ✅ **Capella API Token**: With permissions to configure audit settings
3. ✅ **Guardium Data Protection**: Version 12.2.1 or above installed
4. ✅ **Guardium OAuth Client**: Registered via `grdapi register_oauth_client`

## Step-by-Step Guide

### Step 1: Gather Capella Cluster Information

Log into your Capella console and collect:

```
Organization ID: ___________________________
Project ID:      ___________________________
Cluster ID:      ___________________________
API Token:       ___________________________
```

**How to find these:**
1. Go to https://cloud.couchbase.com
2. Click on your cluster
3. Look in the URL or cluster details page
4. Copy the IDs

### Step 2: Configure Variables

Copy the example file and fill in your values:

```bash
cd examples/couchbase-capella
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
# Your Capella cluster (from Step 1)
capella_organization_id = "org-abc-123"
capella_project_id      = "proj-def-456"
capella_cluster_id      = "cluster-ghi-789"
capella_api_token       = "your-capella-api-token"

# Audit Log Settings (example)
auditlogsettings = {
  audit_enabled     = true
  enabled_event_ids = [20485, 28672, 28675, 28676, 28678, 28679, 28682, 28686, 28687, 45074]
  disabled_users    = []
}

# Your Guardium server
gdp_server        = "guardium.example.com"
gdp_username      = "admin"
gdp_password      = "your-password"
gdp_client_secret = "your-oauth-secret"
gdp_mu_host       = "guardium-mu.example.com"

# Universal Connector Configuration
enable_universal_connector = true
csv_query_interval        = "3600"
csv_query_length          = "3600"
csv_description           = "Guardium connector for Capella"
```

### Step 3: Run Terraform

```bash
# Initialize Terraform
terraform init

# Preview what will be configured
terraform plan

# Apply the configuration
terraform apply
```

Type `yes` when prompted.

### Step 4: Verify

After Terraform completes:

1. **In Capella Console**:
   - Go to your cluster settings
   - Verify audit logging is enabled

2. **In Guardium Console**:
   - Navigate to Universal Connector
   - Look for connector named `capella-{project-id}-{cluster-id}`
   - Verify it's polling successfully

3. **Check Audit Logs**:
   - Perform some operations on your Capella cluster
   - Wait for the polling interval (default: 1 hour)
   - Check Guardium dashboard for audit events

## What Gets Configured

When you run this example:

```
┌─────────────────────────────────────────┐
│  Your Existing Capella Cluster          │
│  (No changes to cluster itself)         │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Audit Logging Enabled                  │
│  ✓ Authentication events                │
│  ✓ Authorization events                 │
│  ✓ Data access events                   │
│  ✓ Admin operations                     │
│  ✓ Query operations                     │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Universal Connector Configured         │
│  ✓ Polls Capella API every 5 minutes    │
│  ✓ Reads audit logs via REST            │
│  ✓ Parses and normalizes events         │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Guardium Data Protection               │
│  ✓ Receives audit events                │
│  ✓ Monitors for threats                 │
│  ✓ Generates compliance reports         │
└─────────────────────────────────────────┘
```

## Configuration Options

### Audit Events

You can customize which events to audit:

```hcl
audit_events = [
  "authentication",      # User login/logout
  "authorization",       # Permission checks
  "data_access",        # Read/write operations
  "admin_operations",   # Administrative actions
  "query_operations"    # N1QL queries
]
```

### Exclude Users from Auditing

To exclude specific users:

```hcl
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
```

### Polling Interval

Adjust how often Guardium polls for new logs (in seconds):

```hcl
csv_query_interval = "3600"  # Poll every 60 minutes (3600 seconds)
csv_query_length   = "3600"  # Query length in seconds
```

## Troubleshooting

### Error: "Failed to enable audit logging"

**Cause**: Capella API token doesn't have correct permissions

**Solution**:
1. Verify your API token in Capella console
2. Ensure it has audit configuration permissions
3. Check `capella_api_token` variable is set correctly in terraform.tfvars

### No Audit Logs Appearing in Guardium

**Possible causes**:

1. **Network connectivity**: Guardium can't reach Capella API
   - Check firewall rules
   - Verify `cloudapi.cloud.couchbase.com` is accessible

2. **Credential issues**: API token expired or invalid
   - Regenerate token in Capella
   - Update `capella_api_token` in terraform.tfvars
   - Run `terraform apply` again

3. **Polling not started**: Universal Connector not active
   - Check UC status in Guardium console
   - Review UC logs for errors
   - Verify `enable_universal_connector = true`

4. **No activity**: No operations on cluster to audit
   - Perform some database operations
   - Wait for next polling interval (default: 3600 seconds / 1 hour)

5. **Configuration changes not applied**: Changed `csv_query_interval` but not seeing updates
   - Use `terraform taint` to force recreation of Guardium resources
   - See troubleshooting section in module README

### How to Check Logs

**In Guardium:**
```
1. Navigate to: Reports → Audit Reports
2. Filter by datasource: capella-{your-cluster-id}
3. Check for recent events
```

**Universal Connector Status:**
```
1. Go to: Administration → Universal Connector
2. Find your Capella connector
3. Check status and last poll time
```

## Cleanup

To remove the audit configuration:

```bash
terraform destroy
```

This will:
- Disable audit logging on the Capella cluster
- Remove the Universal Connector configuration from Guardium
- **NOT** delete your Capella cluster (it remains running)

## Files in This Example

```
examples/couchbase-capella/
├── main.tf                      # Main configuration
├── variables.tf                 # Variable definitions
├── versions.tf                  # Provider requirements
├── terraform.tfvars.example     # Example values
└── README.md                    # This file
```

## Next Steps

After successfully enabling audit logging:

1. **Configure Policies**: Set up security policies in Guardium
2. **Set Up Alerts**: Configure alerts for suspicious activity
3. **Create Reports**: Generate compliance reports
4. **Monitor Dashboard**: Regularly check Guardium dashboard

## Important Notes

- ⚠️ This example assumes your Capella cluster already exists
- ⚠️ Audit logging may incur additional Capella costs
- ⚠️ Store API tokens and passwords securely
- ⚠️ Capella API has rate limits; adjust polling interval if needed
- ⚠️ Audit logs are retained for a limited time in Capella

## Additional Resources

- [Couchbase Capella Documentation](https://docs.couchbase.com/cloud/)
- [Guardium Data Protection Documentation](https://www.ibm.com/docs/en/guardium)
- [Guardium Universal Connector Guide](https://www.ibm.com/docs/en/guardium/12.2?topic=connectors-universal-connector)
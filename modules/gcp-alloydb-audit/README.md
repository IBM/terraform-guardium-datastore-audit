# GCP AlloyDB Audit Module

This module configures audit logging for Google Cloud AlloyDB clusters and registers them with Guardium Data Protection via Pub/Sub.

## Overview

This module integrates an existing AlloyDB cluster with Guardium Data Protection by:
- Connecting to an existing AlloyDB cluster
- Using a pre-configured Pub/Sub subscription for audit logs
- Registering the cluster with Guardium Universal Connector
- Enabling real-time audit log monitoring

## Prerequisites

1. **AlloyDB Infrastructure**: Use the `guardium-terraform/setup-middleware/gcp-alloydb` module to create:
   - AlloyDB cluster with audit logging enabled
   - Pub/Sub topic and subscription
   - Cloud Logging sink configuration

2. **GCP Credentials**: Service account configured in Guardium with permissions:
   - `pubsub.subscriptions.consume`
   - `pubsub.subscriptions.get`

3. **Guardium Setup**:
   - Guardium Data Protection instance
   - OAuth client registered
   - GCP credentials configured

## Usage

### Complete Example with Infrastructure Setup

```hcl
# Step 1: Create AlloyDB infrastructure
module "alloydb_setup" {
  source = "path/to/guardium-terraform/setup-middleware/gcp-alloydb"

  gcp_project_id = "my-gcp-project"
  gcp_region     = "us-central1"
  cluster_name   = "guardium-alloydb"
  db_password    = var.db_password
}

# Step 2: Configure audit logging and register with Guardium
module "alloydb_audit" {
  source = "path/to/terraform-guardium-datastore-audit/modules/gcp-alloydb-audit"

  # Use outputs from setup module
  gcp_project_id         = module.alloydb_setup.gcp_project_id
  gcp_region             = module.alloydb_setup.gcp_region
  alloydb_cluster_id     = module.alloydb_setup.cluster_name
  pubsub_subscription_id = module.alloydb_setup.pubsub_subscription_name

  # Guardium Configuration
  udc_gcp_credential = "gcp-service-account"
  gdp_client_id      = var.gdp_client_id
  gdp_client_secret  = var.gdp_client_secret
  gdp_server         = var.gdp_server
  gdp_username       = var.gdp_username
  gdp_password       = var.gdp_password
  gdp_mu_host        = var.gdp_mu_host
}
```

### Using with Existing AlloyDB Cluster

If you already have an AlloyDB cluster with Pub/Sub configured:

```hcl
module "alloydb_audit" {
  source = "path/to/terraform-guardium-datastore-audit/modules/gcp-alloydb-audit"

  # Existing AlloyDB Configuration
  gcp_project_id         = "my-gcp-project"
  gcp_region             = "us-central1"
  alloydb_cluster_id     = "existing-alloydb-cluster"
  pubsub_subscription_id = "existing-audit-logs-sub"

  # Guardium Configuration
  udc_gcp_credential = "gcp-service-account"
  gdp_client_id      = var.gdp_client_id
  gdp_client_secret  = var.gdp_client_secret
  gdp_server         = "guardium.example.com"
  gdp_username       = "admin"
  gdp_password       = var.gdp_password
  gdp_mu_host        = "guardium-mu-1,guardium-mu-2"

  # Optional: Pub/Sub Configuration
  threads      = 8
  max_messages = 100
  ack_deadline = 60
}
```

## Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `gcp_project_id` | GCP project ID | `string` |
| `alloydb_cluster_id` | AlloyDB cluster identifier | `string` |
| `pubsub_subscription_id` | Pub/Sub subscription ID | `string` |
| `udc_gcp_credential` | GCP credential name in Guardium | `string` |
| `gdp_client_id` | Guardium OAuth client ID | `string` |
| `gdp_client_secret` | Guardium OAuth client secret | `string` |
| `gdp_server` | Guardium server hostname/IP | `string` |
| `gdp_username` | Guardium username | `string` |
| `gdp_password` | Guardium password | `string` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `gcp_region` | GCP region | `string` | `"us-central1"` |
| `udc_name` | Universal connector name | `string` | `"alloydb-audit"` |
| `gdp_port` | Guardium port | `string` | `"8443"` |
| `gdp_mu_host` | Guardium Managed Units | `string` | `""` |
| `enable_universal_connector` | Enable UC | `bool` | `true` |
| `csv_start_position` | Start position | `string` | `"end"` |
| `threads` | Pub/Sub threads | `number` | `8` |
| `max_messages` | Max messages per pull | `number` | `100` |
| `ack_deadline` | Ack deadline (seconds) | `number` | `60` |

## Outputs

| Name | Description |
|------|-------------|
| `alloydb_cluster_id` | AlloyDB cluster identifier |
| `pubsub_subscription_id` | Pub/Sub subscription ID |
| `gcp_project_id` | GCP project ID |
| `gcp_region` | GCP region |
| `universal_connector_enabled` | UC enabled status |

## Architecture

```
AlloyDB Cluster
    ↓ (audit logs)
Cloud Logging
    ↓ (log sink)
Pub/Sub Topic
    ↓ (subscription)
Guardium Universal Connector ← This Module
    ↓
Guardium Data Protection
```

## Audit Log Configuration

The AlloyDB cluster should be configured with these database flags (handled by setup-middleware):

```hcl
database_flags = {
  "cloudsql.enable_pgaudit"           = "on"
  "pgaudit.log"                       = "all"
  "pgaudit.log_catalog"               = "on"
  "pgaudit.log_parameter"             = "on"
  "pgaudit.log_relation"              = "on"
  "pgaudit.log_statement_once"        = "off"
  "log_connections"                   = "on"
  "log_disconnections"                = "on"
  "log_duration"                      = "on"
  "log_lock_waits"                    = "on"
  "log_statement"                     = "all"
  "log_min_duration_statement"        = "0"
}
```

## Monitoring

### Verify Audit Logs

Check if audit logs are being generated:
```bash
gcloud logging read "resource.type=alloydb.googleapis.com/Instance" \
  --project=PROJECT_ID \
  --limit=10
```

### Check Pub/Sub Messages

Verify messages in subscription:
```bash
gcloud pubsub subscriptions pull SUBSCRIPTION_NAME \
  --project=PROJECT_ID \
  --limit=5
```

### Guardium Universal Connector Status

Check UC status in Guardium:
1. Navigate to Setup → Tools → Universal Connector
2. Find the AlloyDB connector
3. Verify status is "Running"
4. Check message count and errors

## Troubleshooting

### No Audit Logs

1. **Check Database Flags**: Ensure pgAudit is enabled
   ```bash
   gcloud alloydb instances describe INSTANCE_NAME \
     --cluster=CLUSTER_NAME \
     --region=REGION
   ```

2. **Verify Log Sink**: Check log sink configuration
   ```bash
   gcloud logging sinks describe SINK_NAME
   ```

3. **Check Pub/Sub Topic**: Verify messages are published
   ```bash
   gcloud pubsub topics list
   ```

### Universal Connector Not Receiving Messages

1. **Check Credentials**: Verify GCP credentials in Guardium
2. **Check Subscription**: Ensure subscription exists and has messages
3. **Check IAM Permissions**: Verify service account has required permissions
4. **Review UC Logs**: Check Guardium UC logs for errors

### High Message Latency

1. **Increase Threads**: Set `threads` to higher value (e.g., 16)
2. **Increase Max Messages**: Set `max_messages` to higher value (e.g., 500)
3. **Adjust Ack Deadline**: Increase `ack_deadline` if processing is slow

## Best Practices

1. **Start Position**: Use `"end"` for production to avoid processing old logs
2. **Thread Count**: Adjust based on log volume (8-16 for most cases)
3. **Message Batching**: Use higher `max_messages` for high-volume environments
4. **Monitoring**: Set up alerts for UC status and message backlog
5. **Credentials**: Use dedicated service account with minimal permissions
6. **Testing**: Test with `enable_universal_connector = false` first

## Security Considerations

1. **Service Account**: Use dedicated service account for Guardium
2. **Least Privilege**: Grant only required Pub/Sub permissions
3. **Credential Storage**: Store credentials securely (e.g., Secret Manager)
4. **Network Security**: Use private networking for AlloyDB
5. **Audit Logs**: Monitor access to audit logs themselves

## Related Modules

- `guardium-terraform/setup-middleware/gcp-alloydb`: AlloyDB infrastructure setup
- `terraform-guardium-common/modules/alloydb-pubsub-registration`: Pub/Sub registration
- `terraform-guardium-gdp/modules/connect-datasource-to-uc`: Universal Connector integration

## Support

For issues or questions:
- [AlloyDB Documentation](https://cloud.google.com/alloydb/docs)
- [Guardium Documentation](https://www.ibm.com/docs/en/guardium)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

## License

Copyright IBM Corp. 2025
SPDX-License-Identifier: Apache-2.0
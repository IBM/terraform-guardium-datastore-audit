# GCP AlloyDB Audit Module

This module configures audit transport resources for AlloyDB PostgreSQL logs and registers the datasource with Guardium.

## What this module does

Use this module with an existing AlloyDB deployment.

It:
- optionally creates the Pub/Sub topic and subscription for audit delivery
- optionally creates the Cloud Logging sink for AlloyDB PostgreSQL logs
- optionally grants the sink permission to publish to Pub/Sub
- registers the AlloyDB datasource with Guardium Universal Connector

It does not create the AlloyDB cluster itself.

## Prerequisites

You need:
- an existing AlloyDB cluster
- a GCP credential in Guardium with access to the Pub/Sub subscription
- a Guardium OAuth client for API-based registration

## Usage

```hcl
module "alloydb_audit" {
  source = "path/to/terraform-guardium-datastore-audit/modules/gcp-alloydb-audit"

  gcp_project_id         = "my-gcp-project"
  gcp_region             = "us-central1"
  alloydb_cluster_id     = "existing-alloydb-cluster"
  pubsub_topic_id        = "guardium-alloydb-audit-logs"
  pubsub_subscription_id = "guardium-alloydb-audit-logs-sub"

  udc_gcp_credential = "gcp-service-account"
  gdp_server         = "guardium.example.com"
  gdp_username       = "admin"
  gdp_password       = var.gdp_password
  gdp_client_id      = var.gdp_client_id
  gdp_client_secret  = var.gdp_client_secret
  gdp_mu_host        = "mu1.example.com,mu2.example.com"
}
```

## Key inputs

Required:
- `gcp_project_id`
- `alloydb_cluster_id`
- `pubsub_topic_id`
- `pubsub_subscription_id`
- `udc_gcp_credential`
- `gdp_client_id`
- `gdp_client_secret`
- `gdp_server`
- `gdp_username`
- `gdp_password`

Common optional inputs:
- `gcp_region` default: `us-central1`
- `enable_audit_logging` default: `true` (`true` creates topic/subscription/sink, `false` uses existing topic/subscription)
- `audit_log_sink_name` default: empty, which uses `<alloydb_cluster_id>-audit-sink`
- `pubsub_ack_deadline` default: `60`
- `enable_universal_connector` default: `true`
- `csv_start_position` default: `end`
- `max_messages` default: `100`

## Outputs

- `alloydb_cluster_id`
- `pubsub_topic_name`
- `pubsub_subscription_id`
- `log_sink_name`
- `log_sink_writer_identity`
- `gcp_project_id`
- `gcp_region`
- `universal_connector_enabled`

## Logging filter

When `enable_audit_logging = true`, this module creates a Cloud Logging sink with this filter. When `false`, you must provide existing Pub/Sub topic and subscription IDs:

```text
((resource.type="alloydb.googleapis.com/Instance" logName="projects/<project-id>/logs/alloydb.googleapis.com%2Fpostgres.log" ))
```

`<project-id>` is rendered from `gcp_project_id`.

## Verify

### Check Cloud Logging

```bash
gcloud logging read \
  'resource.type="alloydb.googleapis.com/Instance" AND logName="projects/my-gcp-project/logs/alloydb.googleapis.com%2Fpostgres.log"' \
  --project=my-gcp-project \
  --limit=10
```

### Check Pub/Sub delivery

```bash
gcloud pubsub subscriptions pull \
  guardium-alloydb-audit-logs-sub \
  --project=my-gcp-project \
  --limit=5
```

### Check Guardium

In Guardium, go to **Setup → Tools → Universal Connector** and verify the AlloyDB connector is running and receiving messages.

## Troubleshooting

### No logs in Pub/Sub
- confirm the AlloyDB cluster exists and is producing PostgreSQL logs
- confirm the required AlloyDB audit-related database flags are enabled
- confirm the logging sink exists and is targeting the expected Pub/Sub topic

### Guardium not receiving messages
- confirm the Guardium GCP credential is valid
- confirm the subscription contains messages
- review Universal Connector logs in Guardium

## Related modules

- `terraform-guardium-common/modules/alloydb-pubsub-registration`
- `terraform-guardium-gdp/modules/connect-datasource-to-uc`

## License

Copyright IBM Corp. 2026
SPDX-License-Identifier: Apache-2.0
# GCP AlloyDB Audit Example

This example configures audit transport resources for AlloyDB PostgreSQL logs and registers the datasource with Guardium.

## What this example does

Use this example with an existing AlloyDB deployment.

It:
- creates the Pub/Sub topic and subscription for audit delivery
- creates the Cloud Logging sink for AlloyDB PostgreSQL logs
- grants the sink permission to publish to Pub/Sub
- registers the AlloyDB datasource with Guardium Universal Connector

It does not create the AlloyDB cluster itself.

## Prerequisites

You need:
- an existing AlloyDB cluster
- a GCP credential in Guardium with access to the Pub/Sub subscription
- a Guardium OAuth client for API-based registration

Example OAuth client registration:

```bash
grdapi register_oauth_client client_id="{YOUR_CLIENT_ID}}"
```

## Usage

### 1. Configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Set values such as:

```hcl
gcp_project_id         = "my-gcp-project"
gcp_region             = "us-central1"
alloydb_cluster_id     = "guardium-alloydb-cluster"
pubsub_topic_id        = "guardium-alloydb-audit-logs"
pubsub_subscription_id = "guardium-alloydb-audit-logs-sub"

udc_gcp_credential = "gcp-service-account"
gdp_server         = "guardium.example.com"
gdp_username       = "admin"
gdp_password       = "your-password"
gdp_client_id      = "client4"
gdp_client_secret  = "your-client-secret"
gdp_mu_host        = "mu1.example.com,mu2.example.com"
```

### 2. Apply

```bash
terraform init
terraform plan
terraform apply
```

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

## Cleanup

```bash
terraform destroy
```

This removes the Pub/Sub, Cloud Logging, and Guardium registration resources created by this example.

## License

Copyright IBM Corp. 2025
SPDX-License-Identifier: Apache-2.0
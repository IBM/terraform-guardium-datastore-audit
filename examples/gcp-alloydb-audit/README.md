# GCP AlloyDB Audit Example

This example demonstrates how to configure audit logging for a GCP AlloyDB cluster and register it with Guardium Data Protection using Pub/Sub.

## Overview

This example shows the complete workflow for monitoring AlloyDB with Guardium:

1. **Infrastructure Setup** (prerequisite): Deploy AlloyDB with audit logging using `guardium-terraform/setup-middleware/gcp-alloydb`
2. **Audit Registration** (this example): Register the AlloyDB cluster with Guardium Universal Connector

## Prerequisites

### 1. AlloyDB Infrastructure

First, deploy the AlloyDB infrastructure using the setup-middleware module:

```bash
cd ../../../guardium-terraform/setup-middleware/gcp-alloydb
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform apply
```

This creates:
- AlloyDB cluster with audit logging enabled
- Pub/Sub topic and subscription
- Cloud Logging sink
- All necessary networking and IAM

### 2. GCP Credentials in Guardium

Configure GCP service account credentials in Guardium:

1. Create a GCP service account with permissions:
   - `pubsub.subscriptions.consume`
   - `pubsub.subscriptions.get`

2. Download the service account key JSON

3. In Guardium, navigate to: **Setup → Tools → Credentials**

4. Add new GCP credential with the service account key

### 3. Guardium OAuth Client

Register an OAuth client for API access:

```bash
grdapi register_oauth_client \
  --client-id client4 \
  --guardium-host guardium.example.com \
  --guardium-port 8443 \
  --guardium-user admin
```

Save the client secret returned.

## Usage

### Step 1: Configure Variables

Copy the example configuration:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
# GCP Configuration
gcp_project_id         = "my-gcp-project"
gcp_region             = "us-central1"
alloydb_cluster_id     = "guardium-alloydb-cluster"
pubsub_subscription_id = "guardium-alloydb-cluster-audit-logs-sub"

# Guardium Configuration
udc_gcp_credential = "gcp-service-account"
gdp_server         = "guardium.example.com"
gdp_username       = "admin"
gdp_password       = "your-password"
gdp_client_id      = "client4"
gdp_client_secret  = "your-client-secret"
gdp_mu_host        = "mu1.example.com,mu2.example.com"
```

### Step 2: Initialize Terraform

```bash
terraform init
```

### Step 3: Review the Plan

```bash
terraform plan
```

### Step 4: Apply the Configuration

```bash
terraform apply
```

This will:
- Register the AlloyDB cluster with Guardium
- Configure the Universal Connector
- Start monitoring audit logs via Pub/Sub

### Step 5: Verify in Guardium

1. Navigate to **Setup → Tools → Universal Connector**
2. Find your AlloyDB connector
3. Verify status is "Running"
4. Check that messages are being received

## Configuration Options

### Pub/Sub Settings

Adjust these based on your audit log volume:

```hcl
# For high-volume environments
threads      = 16
max_messages = 500
ack_deadline = 120

# For low-volume environments
threads      = 4
max_messages = 50
ack_deadline = 30
```

### Start Position

```hcl
# Process only new logs (recommended for production)
csv_start_position = "end"

# Process all historical logs (use with caution)
csv_start_position = "beginning"
```

## Monitoring

### Check Audit Logs

View audit logs in Cloud Logging:

```bash
gcloud logging read \
  "resource.type=alloydb.googleapis.com/Instance
   resource.labels.cluster_id=guardium-alloydb-cluster" \
  --project=my-gcp-project \
  --limit=10
```

### Check Pub/Sub Messages

View messages in the subscription:

```bash
gcloud pubsub subscriptions pull \
  guardium-alloydb-cluster-audit-logs-sub \
  --project=my-gcp-project \
  --limit=5
```

### Monitor Universal Connector

In Guardium:
1. Go to **Setup → Tools → Universal Connector**
2. Select your AlloyDB connector
3. View:
   - Connection status
   - Messages received
   - Error count
   - Last activity timestamp

## Troubleshooting

### No Audit Logs Appearing

1. **Verify AlloyDB Configuration**:
   ```bash
   gcloud alloydb instances describe INSTANCE_NAME \
     --cluster=CLUSTER_NAME \
     --region=REGION \
     --project=PROJECT_ID
   ```
   Check that audit logging flags are enabled.

2. **Check Log Sink**:
   ```bash
   gcloud logging sinks describe SINK_NAME \
     --project=PROJECT_ID
   ```
   Verify the sink is active and filter is correct.

3. **Verify Pub/Sub Topic**:
   ```bash
   gcloud pubsub topics list --project=PROJECT_ID
   ```
   Ensure the topic exists and has messages.

### Universal Connector Not Receiving Messages

1. **Check GCP Credentials**: Verify credentials in Guardium are correct
2. **Check IAM Permissions**: Ensure service account has required permissions
3. **Review UC Logs**: Check Guardium logs for connection errors
4. **Test Subscription**: Pull messages manually to verify they exist

### High Message Latency

1. Increase `threads` value (e.g., 16 or 32)
2. Increase `max_messages` value (e.g., 500)
3. Increase `ack_deadline` if processing is slow
4. Check Guardium system resources

## Complete Example with Infrastructure

For a complete end-to-end example including infrastructure setup:

```hcl
# Step 1: Deploy AlloyDB infrastructure
module "alloydb_setup" {
  source = "../../../guardium-terraform/setup-middleware/gcp-alloydb"

  gcp_project_id = "my-gcp-project"
  gcp_region     = "us-central1"
  cluster_name   = "guardium-alloydb"
  db_password    = var.db_password
}

# Step 2: Register with Guardium
module "alloydb_audit" {
  source = "../../modules/gcp-alloydb-audit"

  gcp_project_id         = module.alloydb_setup.gcp_project_id
  gcp_region             = module.alloydb_setup.gcp_region
  alloydb_cluster_id     = module.alloydb_setup.cluster_name
  pubsub_subscription_id = module.alloydb_setup.pubsub_subscription_name

  udc_gcp_credential = "gcp-service-account"
  gdp_client_id      = var.gdp_client_id
  gdp_client_secret  = var.gdp_client_secret
  gdp_server         = var.gdp_server
  gdp_username       = var.gdp_username
  gdp_password       = var.gdp_password
  gdp_mu_host        = var.gdp_mu_host
}
```

## Cleanup

To remove the audit configuration:

```bash
terraform destroy
```

**Note**: This only removes the Guardium registration. To delete the AlloyDB infrastructure, run `terraform destroy` in the setup-middleware directory.

## Security Best Practices

1. **Credentials**: Store sensitive values in environment variables or secret management systems
2. **Service Account**: Use dedicated service account with minimal permissions
3. **Network**: Keep AlloyDB in private network
4. **Monitoring**: Set up alerts for UC failures
5. **Audit**: Regularly review audit logs for suspicious activity

## Related Documentation

- [AlloyDB Documentation](https://cloud.google.com/alloydb/docs)
- [Guardium Data Protection](https://www.ibm.com/docs/en/guardium)
- [GCP Pub/Sub](https://cloud.google.com/pubsub/docs)
- [Setup Middleware Module](../../../guardium-terraform/setup-middleware/gcp-alloydb/README.md)
- [Audit Module](../../modules/gcp-alloydb-audit/README.md)

## Support

For issues or questions:
- Check the troubleshooting section above
- Review Guardium logs
- Consult GCP Cloud Logging
- Contact IBM Guardium support

## License

Copyright IBM Corp. 2025
SPDX-License-Identifier: Apache-2.0
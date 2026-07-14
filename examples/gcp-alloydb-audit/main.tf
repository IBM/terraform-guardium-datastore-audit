#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

/**
 * # GCP AlloyDB with Universal Connector - Audit Logging
 *
 * This example demonstrates how to configure GCP AlloyDB with Guardium Universal Connector
 * using Pub/Sub for audit log delivery.
 *
 * ## Usage
 *
 * This example uses an existing AlloyDB deployment.
 *
 * This module creates the Pub/Sub topic, Pub/Sub subscription, and Cloud Logging sink,
 * then registers the AlloyDB cluster with Guardium for monitoring.
 */

# Configure GCP provider
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Configure Guardium Data Protection provider
provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}

module "alloydb_audit" {
  source = "../../modules/gcp-alloydb-audit"

  # GCP configuration
  gcp_project_id         = var.gcp_project_id
  gcp_region             = var.gcp_region
  alloydb_cluster_id     = var.alloydb_cluster_id
  pubsub_topic_id        = var.pubsub_topic_id
  pubsub_subscription_id = var.pubsub_subscription_id
  enable_audit_logging   = var.enable_audit_logging
  audit_log_sink_name    = var.audit_log_sink_name
  pubsub_ack_deadline    = var.pubsub_ack_deadline

  # Guardium configuration
  udc_name           = var.udc_name
  udc_gcp_credential = var.udc_gcp_credential
  gdp_client_secret  = var.gdp_client_secret
  gdp_client_id      = var.gdp_client_id
  gdp_server         = var.gdp_server
  gdp_port           = var.gdp_port
  gdp_username       = var.gdp_username
  gdp_password       = var.gdp_password
  gdp_mu_host        = var.gdp_mu_host

  # Universal Connector configuration
  enable_universal_connector = var.enable_universal_connector
  csv_start_position         = var.csv_start_position
  max_messages               = var.max_messages
}
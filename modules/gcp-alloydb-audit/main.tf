#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Get GCP project details
data "google_project" "current" {
  project_id = var.gcp_project_id
}

# Get AlloyDB cluster details
data "google_alloydb_cluster" "cluster_metadata" {
  cluster_id = var.alloydb_cluster_id
  location   = var.gcp_region
}

locals {
  alloydb_audit_log_filter = "((resource.type=\"alloydb.googleapis.com/Instance\" logName=\"projects/${var.gcp_project_id}/logs/alloydb.googleapis.com%2Fpostgres.log\" ))"
}

resource "google_pubsub_topic" "alloydb_audit_logs" {
  count = var.enable_audit_logging ? 1 : 0

  name = var.pubsub_topic_id
}

resource "google_pubsub_subscription" "alloydb_audit_subscription" {
  count = var.enable_audit_logging ? 1 : 0

  name  = var.pubsub_subscription_id
  topic = google_pubsub_topic.alloydb_audit_logs[0].name

  ack_deadline_seconds       = var.pubsub_ack_deadline
  message_retention_duration = "604800s"

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }
}

resource "google_logging_project_sink" "alloydb_audit_sink" {
  count = var.enable_audit_logging ? 1 : 0

  name        = var.audit_log_sink_name != "" ? var.audit_log_sink_name : "${var.alloydb_cluster_id}-audit-sink"
  destination = "pubsub.googleapis.com/${google_pubsub_topic.alloydb_audit_logs[0].id}"
  filter      = local.alloydb_audit_log_filter

  unique_writer_identity = true
}

resource "google_pubsub_topic_iam_member" "alloydb_audit_sink_publisher" {
  count = var.enable_audit_logging ? 1 : 0

  project = var.gcp_project_id
  topic   = google_pubsub_topic.alloydb_audit_logs[0].name
  role    = "roles/pubsub.publisher"
  member  = google_logging_project_sink.alloydb_audit_sink[0].writer_identity
}

# Module to register AlloyDB with Guardium via Pub/Sub
module "alloydb-pubsub-registration" {
  source = "IBM/common/guardium//modules/alloydb-pubsub-registration"

  # GCP Configuration
  gcp_project_id         = var.gcp_project_id
  gcp_region             = var.gcp_region
  alloydb_cluster_id     = var.alloydb_cluster_id
  pubsub_topic_id        = var.pubsub_topic_id
  pubsub_subscription_id = var.pubsub_subscription_id

  # Guardium Configuration
  udc_gcp_credential         = var.udc_gcp_credential
  gdp_client_id              = var.gdp_client_id
  gdp_client_secret          = var.gdp_client_secret
  gdp_server                 = var.gdp_server
  gdp_port                   = var.gdp_port
  gdp_username               = var.gdp_username
  gdp_password               = var.gdp_password
  gdp_mu_host                = var.gdp_mu_host
  enable_universal_connector = var.enable_universal_connector

  # Pub/Sub Configuration
  csv_start_position = var.csv_start_position
  max_messages       = var.max_messages
}

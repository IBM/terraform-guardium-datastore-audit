#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "alloydb_cluster_id" {
  description = "The AlloyDB cluster identifier being monitored"
  value       = var.alloydb_cluster_id
}

output "pubsub_topic_name" {
  description = "The Pub/Sub topic name used for audit logs"
  value       = var.enable_audit_logging ? google_pubsub_topic.alloydb_audit_logs[0].name : var.pubsub_topic_id
}

output "pubsub_subscription_id" {
  description = "The Pub/Sub subscription ID used for audit logs"
  value       = var.enable_audit_logging ? google_pubsub_subscription.alloydb_audit_subscription[0].name : var.pubsub_subscription_id
}

output "log_sink_name" {
  description = "The Cloud Logging sink name used for AlloyDB audit logs"
  value       = var.enable_audit_logging ? google_logging_project_sink.alloydb_audit_sink[0].name : null
}

output "log_sink_writer_identity" {
  description = "The Cloud Logging sink writer identity"
  value       = var.enable_audit_logging ? google_logging_project_sink.alloydb_audit_sink[0].writer_identity : null
}

output "gcp_project_id" {
  description = "The GCP project ID"
  value       = var.gcp_project_id
}

output "gcp_region" {
  description = "The GCP region"
  value       = var.gcp_region
}

output "universal_connector_enabled" {
  description = "Whether the universal connector is enabled"
  value       = var.enable_universal_connector
}
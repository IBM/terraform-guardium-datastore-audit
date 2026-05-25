#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

output "alloydb_cluster_id" {
  description = "The AlloyDB cluster identifier being monitored"
  value       = var.alloydb_cluster_id
}

output "pubsub_subscription_id" {
  description = "The Pub/Sub subscription ID used for audit logs"
  value       = var.pubsub_subscription_id
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
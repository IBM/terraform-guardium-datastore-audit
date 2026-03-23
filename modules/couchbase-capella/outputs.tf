#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Couchbase Capella Audit Configuration Module - Outputs

output "profile_csv" {
  value       = local.capella_uc_csv
  description = "Content of the profile CSV"
  sensitive   = true
}

output "udc_name" {
  value       = local.udc_name
  description = "Name of the Universal Connector"
}

output "capella_organization_id" {
  value       = var.capella_organization_id
  description = "Capella organization ID"
}

output "capella_project_id" {
  value       = var.capella_project_id
  description = "Capella project ID"
}

output "capella_cluster_id" {
  value       = var.capella_cluster_id
  description = "Capella cluster ID"
}

output "audit_enabled" {
  value       = couchbase-capella_audit_log_settings.auditlogsettings.audit_enabled
  description = "Whether audit logging is enabled"
}

output "enabled_event_ids" {
  value       = couchbase-capella_audit_log_settings.auditlogsettings.enabled_event_ids
  description = "List of enabled audit event IDs"
}

output "api_base_url" {
  value       = local.api_base_url
  description = "Capella API base URL"
}

output "csv_query_interval" {
  value       = var.csv_query_interval
  description = "Query interval in seconds"
}

output "csv_query_length" {
  value       = var.csv_query_length
  description = "Query length in seconds"
}

output "universal_connector_enabled" {
  value       = var.enable_universal_connector
  description = "Whether the Universal Connector is enabled"
}

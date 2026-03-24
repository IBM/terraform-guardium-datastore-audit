#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Couchbase Capella Audit Configuration Example - Outputs

output "profile_csv" {
  value       = module.capella_audit.profile_csv
  description = "Content of the profile CSV"
  sensitive   = true
}

output "udc_name" {
  value       = module.capella_audit.udc_name
  description = "Name of the Universal Connector"
}

output "capella_organization_id" {
  value       = module.capella_audit.capella_organization_id
  description = "Capella organization ID"
}

output "capella_project_id" {
  value       = module.capella_audit.capella_project_id
  description = "Capella project ID"
}

output "capella_cluster_id" {
  value       = module.capella_audit.capella_cluster_id
  description = "Capella cluster ID"
}

output "audit_enabled" {
  value       = module.capella_audit.audit_enabled
  description = "Whether audit logging is enabled"
}

output "enabled_event_ids" {
  value       = module.capella_audit.enabled_event_ids
  description = "List of enabled audit event IDs"
}

output "api_base_url" {
  value       = module.capella_audit.api_base_url
  description = "Capella API base URL"
}

output "csv_query_interval" {
  value       = module.capella_audit.csv_query_interval
  description = "Query interval in seconds"
}

output "csv_query_length" {
  value       = module.capella_audit.csv_query_length
  description = "Query length in seconds"
}

output "universal_connector_enabled" {
  value       = module.capella_audit.universal_connector_enabled
  description = "Whether the Universal Connector is enabled"
}

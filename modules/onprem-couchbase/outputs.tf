#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Name of the Universal Connector created for this Couchbase instance"
  value       = local.udc_name
}

output "couchbase_instance_identifier" {
  description = "Identifier of the Couchbase instance"
  value       = var.couchbase_instance_identifier
}

output "audit_logging_enabled" {
  description = "Whether audit logging was enabled on the Couchbase server"
  value       = var.enable_audit_logging
}

output "filebeat_configured" {
  description = "Whether Filebeat was configured on the Couchbase server"
  value       = var.enable_filebeat_setup
}

output "universal_connector_enabled" {
  description = "Whether the Universal Connector was created in Guardium"
  value       = var.enable_universal_connector
}

output "couchbase_audit_log_directory" {
  description = "Directory where Couchbase audit logs are stored"
  value       = var.couchbase_audit_log_directory
}
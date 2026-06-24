#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Name of the Universal Connector created for this Couchbase instance"
  value       = module.datastore-audit_onprem-couchbase.udc_name
}

output "couchbase_instance_identifier" {
  description = "Identifier of the Couchbase instance"
  value       = module.datastore-audit_onprem-couchbase.couchbase_instance_identifier
}

output "audit_logging_enabled" {
  description = "Whether audit logging was enabled on the Couchbase server"
  value       = module.datastore-audit_onprem-couchbase.audit_logging_enabled
}

output "filebeat_configured" {
  description = "Whether Filebeat was configured on the Couchbase server"
  value       = module.datastore-audit_onprem-couchbase.filebeat_configured
}

output "universal_connector_enabled" {
  description = "Whether the Universal Connector was created in Guardium"
  value       = module.datastore-audit_onprem-couchbase.universal_connector_enabled
}

output "couchbase_audit_log_directory" {
  description = "Directory where Couchbase audit logs are stored"
  value       = module.datastore-audit_onprem-couchbase.couchbase_audit_log_directory
}
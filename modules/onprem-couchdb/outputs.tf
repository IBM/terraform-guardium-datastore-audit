#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Name of the Universal Connector created for this CouchDB instance"
  value       = local.udc_name
}

output "couchdb_instance_name" {
  description = "CouchDB instance identifier"
  value       = var.couchdb_instance_identifier
}

output "logstash_port" {
  description = "Logstash port configured for receiving audit logs"
  value       = var.logstash_port
}

output "audit_log_path" {
  description = "Path to CouchDB audit log file being monitored by Filebeat"
  value       = var.couchdb_audit_log_path
}

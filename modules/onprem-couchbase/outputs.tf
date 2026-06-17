#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Name of the Universal Connector created for this Couchbase instance"
  value       = local.udc_name
}

output "couchbase_cluster_name" {
  description = "Couchbase cluster name"
  value       = var.couchbase_cluster_name
}

output "logstash_port" {
  description = "Logstash port configured for receiving audit logs"
  value       = var.logstash_port
}

output "audit_log_path" {
  description = "Path to Couchbase audit log file"
  value       = var.couchbase_audit_log_path
}

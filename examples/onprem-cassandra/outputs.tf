#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Name of the Universal Connector created for this Cassandra instance"
  value       = module.datastore-audit_onprem-cassandra.udc_name
}

output "cassandra_instance_identifier" {
  description = "Identifier of the Cassandra instance"
  value       = module.datastore-audit_onprem-cassandra.cassandra_instance_identifier
}

output "deployment_type" {
  description = "Detected or configured Cassandra deployment type"
  value       = module.datastore-audit_onprem-cassandra.deployment_type
}

output "config_path" {
  description = "Cassandra configuration directory path"
  value       = module.datastore-audit_onprem-cassandra.config_path
}

output "audit_log_path" {
  description = "Path to Cassandra audit log file"
  value       = module.datastore-audit_onprem-cassandra.audit_log_path
}

output "audit_logging_enabled" {
  description = "Whether audit logging was automatically enabled by this module"
  value       = module.datastore-audit_onprem-cassandra.audit_logging_enabled
}

output "filebeat_configured" {
  description = "Whether Filebeat was configured on the Cassandra server"
  value       = module.datastore-audit_onprem-cassandra.filebeat_configured
}

output "universal_connector_enabled" {
  description = "Whether the Universal Connector was created in Guardium"
  value       = module.datastore-audit_onprem-cassandra.universal_connector_enabled
}
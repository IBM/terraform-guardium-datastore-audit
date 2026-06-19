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

output "filebeat_configured" {
  description = "Whether Filebeat was configured on the Cassandra server"
  value       = module.datastore-audit_onprem-cassandra.filebeat_configured
}

output "universal_connector_enabled" {
  description = "Whether the Universal Connector was created in Guardium"
  value       = module.datastore-audit_onprem-cassandra.universal_connector_enabled
}
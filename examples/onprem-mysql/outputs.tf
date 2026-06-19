#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = module.datastore-audit_onprem-mysql.udc_name
}

output "mysql_instance_identifier" {
  description = "MySQL instance identifier"
  value       = module.datastore-audit_onprem-mysql.mysql_instance_identifier
}

output "mysql_host" {
  description = "MySQL server host"
  value       = module.datastore-audit_onprem-mysql.mysql_host
}

output "syslog_port" {
  description = "MySQL server port"
  value       = module.datastore-audit_onprem-mysql.syslog_port
}

output "ssl_enable" {
  description = "Whether SSL is enabled for the connection"
  value       = module.datastore-audit_onprem-mysql.ssl_enable
}

output "ssl_verify" {
  description = "Whether SSL certificate verification is enabled"
  value       = module.datastore-audit_onprem-mysql.ssl_verify
}

output "dns_reverse_lookup_enabled" {
  description = "Whether DNS reverse lookup is enabled"
  value       = module.datastore-audit_onprem-mysql.dns_reverse_lookup_enabled
}
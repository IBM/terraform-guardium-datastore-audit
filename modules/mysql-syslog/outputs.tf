#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = local.udc_name
}

output "mysql_instance_identifier" {
  description = "MySQL instance identifier"
  value       = var.mysql_instance_identifier
}

output "mysql_host" {
  description = "MySQL server host"
  value       = var.mysql_host
}

output "syslog_port" {
  description = "MySQL server port"
  value       = var.syslog_port
}

output "ssl_enable" {
  description = "Whether SSL is enabled for the connection"
  value       = var.ssl_enable
}

output "ssl_verify" {
  description = "Whether SSL certificate verification is enabled"
  value       = var.ssl_verify
}

output "dns_reverse_lookup_enabled" {
  description = "Whether DNS reverse lookup is enabled"
  value       = var.dns_reverse_lookup_enabled
}

#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = local.udc_name
}

output "snowflake_host" {
  description = "Snowflake account hostname used in the JDBC URL"
  value       = var.snowflake_host
}

output "warehouse" {
  description = "Snowflake warehouse used by the Guardium user"
  value       = var.warehouse
}

output "database" {
  description = "Snowflake database in the JDBC URL"
  value       = var.database
}

output "schema" {
  description = "Snowflake schema in the JDBC URL"
  value       = var.schema
}

output "connection_url" {
  description = "JDBC connection URL used by the profile (contains no credentials)"
  value       = local.connection_url
}

output "role_name" {
  description = "Snowflake role used by Guardium (null when enable_audit_setup is false)"
  value       = var.enable_audit_setup ? snowflake_account_role.guardium[0].name : null
}

output "user_name" {
  description = "Snowflake user used by Guardium"
  value       = var.user_name
}

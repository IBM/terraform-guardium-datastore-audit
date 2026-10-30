#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = module.snowflake_audit_kafka.udc_name
}

output "snowflake_host" {
  description = "Snowflake account hostname used in the JDBC URL"
  value       = module.snowflake_audit_kafka.snowflake_host
}

output "warehouse" {
  description = "Snowflake warehouse used by the Guardium user"
  value       = module.snowflake_audit_kafka.warehouse
}

output "database" {
  description = "Snowflake database in the JDBC URL"
  value       = module.snowflake_audit_kafka.database
}

output "schema" {
  description = "Snowflake schema in the JDBC URL"
  value       = module.snowflake_audit_kafka.schema
}

output "connection_url" {
  description = "JDBC connection URL used by the profile (contains no credentials)"
  value       = module.snowflake_audit_kafka.connection_url
}

output "role_name" {
  description = "Snowflake role used by Guardium (null when enable_audit_setup is false)"
  value       = module.snowflake_audit_kafka.role_name
}

output "user_name" {
  description = "Snowflake user used by Guardium"
  value       = module.snowflake_audit_kafka.user_name
}

#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Name of the Universal Connector profile"
  value       = local.udc_name
}

output "profile_csv" {
  description = "Universal Connector profile CSV (Snowflake Over JDBC Connect 2.0)"
  value       = local.snowflake_kafka_csv
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

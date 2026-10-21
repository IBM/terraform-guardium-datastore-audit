#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Name of the Universal Connector profile"
  value       = module.snowflake_audit_kafka.udc_name
}

output "connection_url" {
  description = "JDBC connection URL used by the profile (contains no credentials)"
  value       = module.snowflake_audit_kafka.connection_url
}

output "role_name" {
  description = "Snowflake role used by Guardium"
  value       = module.snowflake_audit_kafka.role_name
}

output "user_name" {
  description = "Snowflake user used by Guardium"
  value       = module.snowflake_audit_kafka.user_name
}

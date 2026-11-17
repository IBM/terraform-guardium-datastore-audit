#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = module.datastore-audit_aws-redshift-audit-kafka.udc_name
}

output "cloudwatch_log_group_connectionlog" {
  description = "Name of the CloudWatch Log Group for connection logs"
  value       = module.datastore-audit_aws-redshift-audit-kafka.cloudwatch_log_group_connectionlog
}

output "cloudwatch_log_group_useractivitylog" {
  description = "Name of the CloudWatch Log Group for user activity logs"
  value       = module.datastore-audit_aws-redshift-audit-kafka.cloudwatch_log_group_useractivitylog
}

output "parameter_group_name" {
  description = "Name of the Redshift parameter group"
  value       = module.datastore-audit_aws-redshift-audit-kafka.parameter_group_name
}

output "uc_mode" {
  description = "Universal Connector mode"
  value       = module.datastore-audit_aws-redshift-audit-kafka.uc_mode
}

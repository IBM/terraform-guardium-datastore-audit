#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Universal connector name"
  value       = local.udc_name
}

output "log_group" {
  description = "CloudWatch log group(s) being monitored"
  value       = local.log_group
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = local.aws_account_id
}

output "aws_region" {
  description = "AWS Region"
  value       = local.aws_region
}
#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Automatic Import Configuration for AWS Redshift
# This file enables automatic import of existing AWS resources to prevent "already exists" errors

# Local variables for import logic
locals {
  # Determine if we should import CloudWatch Log Groups
  should_import_cloudwatch_connectionlog   = var.input_type == "cloudwatch" && var.existing_cloudwatch_log_group_name == ""
  should_import_cloudwatch_useractivitylog = var.input_type == "cloudwatch" && var.existing_cloudwatch_log_group_name == ""

  # Determine if we should import S3 bucket
  should_import_s3_bucket = var.input_type == "s3" && var.existing_s3_bucket_name == ""

  # CloudWatch Log Group names (must match the module's local variables)
  cloudwatch_log_group_base            = var.existing_cloudwatch_log_group_name != "" ? var.existing_cloudwatch_log_group_name : "/aws/redshift/cluster/${var.redshift_cluster_identifier}"
  cloudwatch_log_group_connectionlog   = "${local.cloudwatch_log_group_base}/connectionlog"
  cloudwatch_log_group_useractivitylog = "${local.cloudwatch_log_group_base}/useractivitylog"

  # S3 bucket name (must match the module's local variables)
  aws_account_id = data.aws_caller_identity.current.account_id
  s3_bucket_name = var.existing_s3_bucket_name != "" ? var.existing_s3_bucket_name : "${var.name_prefix}-redshift-logs"
}

# Get AWS account ID
data "aws_caller_identity" "current" {}

# Import existing CloudWatch Log Group for connectionlog only if it should be imported
import {
  for_each = local.should_import_cloudwatch_connectionlog ? toset(["import"]) : toset([])
  to = module.datastore-audit_aws-redshift.aws_cloudwatch_log_group.redshift_connectionlog[0]
  id = local.cloudwatch_log_group_connectionlog
}

# Import existing CloudWatch Log Group for useractivitylog only if it should be imported
import {
  for_each = local.should_import_cloudwatch_useractivitylog ? toset(["import"]) : toset([])
  to = module.datastore-audit_aws-redshift.aws_cloudwatch_log_group.redshift_useractivitylog[0]
  id = local.cloudwatch_log_group_useractivitylog
}

# Import existing S3 bucket only if it should be imported
import {
  for_each = local.should_import_s3_bucket ? toset(["import"]) : toset([])
  to = module.datastore-audit_aws-redshift.aws_s3_bucket.redshift_logs[0]
  id = local.s3_bucket_name
}
#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# AWS S3 Universal Connector Module (using CloudTrail)

module "aws_configuration" {
  source = "IBM/common/guardium//modules/aws-configuration"
}

locals {
  cloudwatch_log_group_name = var.existing_cloudwatch_log_group_name != "" ? var.existing_cloudwatch_log_group_name : "/aws/cloudtrail/${var.name_prefix}"
  cloudtrail_name           = var.existing_cloudtrail_name != "" ? var.existing_cloudtrail_name : "${var.name_prefix}-s3-trail"
  cloudtrail_s3_bucket      = "${var.name_prefix}-s3-cloudtrail"

  # Determine if we're using existing resources
  use_existing_cloudtrail           = var.existing_cloudtrail_name != ""
  use_existing_cloudwatch_log_group = var.existing_cloudwatch_log_group_name != ""

  # Only reference S3 bucket when CloudTrail is enabled
  ct_bucket = var.enable_cloudtrail ? ["${aws_s3_bucket.s3_monitoring[0].arn}/AWSLogs/${module.aws_configuration.aws_account_id}/*"] : []

  # Format CloudWatch Logs Group ARN for CloudTrail (only when CloudTrail is enabled)
  formatted_cloudwatch_logs_group_arn = var.enable_cloudtrail ? (local.use_existing_cloudwatch_log_group ? "${data.aws_cloudwatch_log_group.existing[0].arn}:*" : "${aws_cloudwatch_log_group.s3_monitoring[0].arn}:*") : ""
  s3_monitoring_role                  = replace("${var.name_prefix}_s3_role", "-", "_")
}

# Data source for existing CloudWatch Log Group
# Only query if we're using an existing log group AND CloudTrail is enabled
data "aws_cloudwatch_log_group" "existing" {
  count = var.enable_cloudtrail && local.use_existing_cloudwatch_log_group ? 1 : 0
  name  = var.existing_cloudwatch_log_group_name
}

# CloudWatch Log Group
# Only create if CloudTrail is enabled and we're not using an existing log group
resource "aws_cloudwatch_log_group" "s3_monitoring" {
  count             = var.enable_cloudtrail && !local.use_existing_cloudwatch_log_group ? 1 : 0
  name              = local.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_logs_retention_days
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# S3 Bucket for CloudTrail logs
resource "aws_s3_bucket" "s3_monitoring" {
  count         = var.enable_cloudtrail ? 1 : 0
  bucket        = local.cloudtrail_s3_bucket
  force_destroy = var.force_destroy_bucket
  tags          = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "s3_monitoring" {
  count = var.enable_cloudtrail ? 1 : 0

  statement {
    sid     = "AWSCloudTrailAclCheck"
    effect  = "Allow"
    actions = ["s3:GetBucketAcl"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = [aws_s3_bucket.s3_monitoring[0].arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${var.aws_region}:${module.aws_configuration.aws_account_id}:trail/${local.cloudtrail_name}"]
    }
  }

  statement {
    sid     = "AWSCloudTrailWrite"
    effect  = "Allow"
    actions = ["s3:PutObject"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = local.ct_bucket

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${var.aws_region}:${module.aws_configuration.aws_account_id}:trail/${local.cloudtrail_name}"]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_monitoring" {
  count  = var.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.s3_monitoring[0].id
  policy = data.aws_iam_policy_document.s3_monitoring[0].json

  lifecycle {
    create_before_destroy = true
  }
}

# IAM for CloudTrail -> CloudWatch Logs
data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "s3_monitoring_role" {
  count              = var.enable_cloudtrail ? 1 : 0
  name               = local.s3_monitoring_role
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
  tags               = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_logs" {
  count = var.enable_cloudtrail ? 1 : 0

  statement {
    sid    = "WriteCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = local.use_existing_cloudwatch_log_group ? ["${data.aws_cloudwatch_log_group.existing[0].arn}:log-stream:*"] : ["${aws_cloudwatch_log_group.s3_monitoring[0].arn}:log-stream:*"]
  }
}

resource "aws_iam_policy" "cloudtrail_cloudwatch_logs" {
  count  = var.enable_cloudtrail ? 1 : 0
  name   = replace("${local.cloudtrail_name}_cloudtrail_cloudwatch", "-", "_")
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_logs[0].json
  tags   = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy_attachment" "main" {
  count      = var.enable_cloudtrail ? 1 : 0
  name       = replace("${local.cloudtrail_name}_cloudtrail_cloudwatch-attachment", "-", "_")
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch_logs[0].arn
  roles      = [aws_iam_role.s3_monitoring_role[0].name]

  lifecycle {
    create_before_destroy = true
  }
}

# CloudTrail
resource "aws_cloudtrail" "s3_monitoring" {
  count = var.enable_cloudtrail && !local.use_existing_cloudtrail ? 1 : 0

  depends_on = [
    aws_s3_bucket_policy.s3_monitoring,
    aws_iam_policy_attachment.main
  ]

  name                          = local.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.s3_monitoring[0].id
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  cloud_watch_logs_group_arn    = local.formatted_cloudwatch_logs_group_arn
  cloud_watch_logs_role_arn     = aws_iam_role.s3_monitoring_role[0].arn

  event_selector {
    read_write_type           = "All"
    include_management_events = var.include_management_events

    data_resource {
      type   = "AWS::S3::Object"
      values = length(var.s3_bucket_arns) > 0 ? var.s3_bucket_arns : []
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  # Create a sanitized version of the UDC name for file paths
  udc_name      = format("%s-%s-%s", var.aws_region, var.name_prefix, module.aws_configuration.aws_account_id)
  udc_name_safe = replace(local.udc_name, "/", "-")

  # Generate the CSV content from the template
  udc_csv = templatefile("${path.module}/templates/s3-audit.tpl", {
    udc_name           = local.udc_name_safe
    credential_name    = var.udc_aws_credential
    aws_region         = var.aws_region
    log_group          = local.cloudwatch_log_group_name
    aws_account_id     = module.aws_configuration.aws_account_id
    cluster_name       = local.cloudtrail_name
    start_position     = var.udc_start_position
    interval           = var.udc_interval
    event_filter       = var.udc_event_filter
    description        = var.udc_description
    prefix             = var.udc_prefix
    unmask             = var.udc_unmask
    endpoint           = var.udc_endpoint
    use_aws_bundled_ca = var.udc_use_aws_bundled_ca
  })
}

# Universal Connector module
module "universal_connector" {
  source = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  count  = var.enable_universal_connector ? 1 : 0

  udc_name       = local.udc_name_safe
  udc_csv_parsed = local.udc_csv
  client_id      = var.gdp_client_id
  client_secret  = var.gdp_client_secret
  gdp_server     = var.gdp_server
  gdp_port       = var.gdp_port
  gdp_username   = var.gdp_username
  gdp_password   = var.gdp_password
  gdp_mu_host    = var.gdp_mu_host
}

data "aws_dynamodb_tables" "all" {}

data "aws_dynamodb_table" "tables" {
  count = length(local.dynamodb_tables)
  name  = element(local.dynamodb_tables, count.index)
}

module "common_aws-configuration" {
  source = "IBM/common/guardium//modules/aws-configuration"
}

locals {
  dynamodb_tables           = var.dynamodb_tables == "all" ? data.aws_dynamodb_tables.all.names : split(",", var.dynamodb_tables)
  cloudwatch_log_group_name = var.existing_cloudwatch_log_group_name != "" ? var.existing_cloudwatch_log_group_name : "/aws/cloudtrail/${var.name_prefix}"
  cloudtrail_name           = var.existing_cloudtrail_name != "" ? var.existing_cloudtrail_name : var.name_prefix
  cloudtrail_s3_bucket      = "${var.name_prefix}-cloudtrail"

  # Determine if we're using existing resources
  use_existing_cloudtrail = var.existing_cloudtrail_name != ""
  use_existing_cloudwatch_log_group = var.existing_cloudwatch_log_group_name != ""

  ct_bucket = aws_s3_bucket.dynamodb_monitoring.bucket_prefix == "" ? ["${aws_s3_bucket.dynamodb_monitoring.arn}/AWSLogs/${module.common_aws-configuration.aws_account_id}/*"] : ["${aws_s3_bucket.dynamodb_monitoring.arn}/${aws_s3_bucket.dynamodb_monitoring.bucket_prefix}/AWSLogs/${module.common_aws-configuration.aws_account_id}/*"]

  # Format CloudWatch Logs Group ARN for CloudTrail
  formatted_cloudwatch_logs_group_arn = local.use_existing_cloudwatch_log_group ? "${data.aws_cloudwatch_log_group.existing[0].arn}:*" : "${aws_cloudwatch_log_group.dynamodb_monitoring[0].arn}:*"
  dynamodb_monitoring_role = replace("${var.name_prefix}_role", "-", "_")
}

# Data source for existing CloudWatch Log Group
data "aws_cloudwatch_log_group" "existing" {
  count = local.use_existing_cloudwatch_log_group ? 1 : 0
  name  = var.existing_cloudwatch_log_group_name
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "dynamodb_monitoring" {
  count = local.use_existing_cloudwatch_log_group ? 0 : 1
  name  = local.cloudwatch_log_group_name
  tags  = var.tags

  # Add lifecycle configuration to ensure proper destruction
  lifecycle {
    create_before_destroy = true
  }
}

# S3 Bucket
resource "aws_s3_bucket" "dynamodb_monitoring" {
  bucket        = local.cloudtrail_s3_bucket
  force_destroy = true
  tags          = var.tags

  # Add lifecycle configuration to ensure proper destruction
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "dynamodb_monitoring" {
  statement {
    sid     = "AWSCloudTrailAclCheck"
    effect  = "Allow"
    actions = ["s3:GetBucketAcl"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = [aws_s3_bucket.dynamodb_monitoring.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${var.aws_partition}:cloudtrail:${var.aws_region}:${module.common_aws-configuration.aws_account_id}:trail/${local.cloudtrail_name}"]
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
      values   = ["arn:${var.aws_partition}:cloudtrail:${var.aws_region}:${module.common_aws-configuration.aws_account_id}:trail/${local.cloudtrail_name}"]
    }
  }
}

resource "aws_s3_bucket_policy" "dynamodb_monitoring" {
  bucket = aws_s3_bucket.dynamodb_monitoring.id
  policy = data.aws_iam_policy_document.dynamodb_monitoring.json

  # Add lifecycle configuration to ensure proper destruction
  lifecycle {
    create_before_destroy = true
  }
}

# IAM for CloudTrail -> CW Logs
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

resource "aws_iam_role" "dynamodb_monitoring_role" {
  name               = local.dynamodb_monitoring_role
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
  tags               = var.tags


  # Add lifecycle configuration to ensure proper destruction
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_logs" {
  statement {
    sid    = "WriteCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    # Use the explicit log-stream ARN pattern CloudTrail writes to
    resources = local.use_existing_cloudwatch_log_group ? ["${data.aws_cloudwatch_log_group.existing[0].arn}:log-stream:*"] : ["${aws_cloudwatch_log_group.dynamodb_monitoring[0].arn}:log-stream:*"]
  }
}

resource "aws_iam_policy" "cloudtrail_cloudwatch_logs" {
  name   = replace("${local.cloudtrail_name}_cloudtrail_cloudwatch", "-", "_")
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_logs.json
  tags   = var.tags

  # Add lifecycle configuration to ensure proper destruction
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy_attachment" "main" {
  name       = replace("${local.cloudtrail_name}_cloudtrail_cloudwatch-attachment", "-", "_")
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch_logs.arn
  roles      = [aws_iam_role.dynamodb_monitoring_role.name]

  # Add lifecycle configuration to ensure proper destruction
  lifecycle {
    create_before_destroy = true
  }
}

# CloudTrail
resource "aws_cloudtrail" "dynamodb_monitoring" {
  count = local.use_existing_cloudtrail ? 0 : 1

  depends_on = [
    aws_s3_bucket_policy.dynamodb_monitoring,
    aws_iam_policy_attachment.main
  ]

  name                          = local.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.dynamodb_monitoring.id
  include_global_service_events = false
  cloud_watch_logs_group_arn    = local.formatted_cloudwatch_logs_group_arn
  cloud_watch_logs_role_arn     = aws_iam_role.dynamodb_monitoring_role.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::DynamoDB::Table"
      values = data.aws_dynamodb_table.tables.*.arn
    }
  }

  tags = var.tags

  # Add lifecycle configuration to ensure proper destruction
  lifecycle {
    create_before_destroy = true
  }

  # Force dependency on the IAM role and policy to ensure they're not destroyed before CloudTrail
  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Ensuring CloudTrail is destroyed before IAM resources'"
  }
}

locals {
  # Create a sanitized version of the UDC name for file paths
  udc_name = format("%s-%s-%s", var.aws_region, local.cloudwatch_log_group_name, module.common_aws-configuration.aws_account_id)
  udc_name_safe = replace(local.udc_name, "/", "-")

  # Generate the CSV content from the template
  udc_csv = templatefile("${path.module}/templates/dynamodbCloudwatch.tpl", {
    udc_name        = local.udc_name_safe
    credential_name = var.udc_aws_credential
    aws_region      = var.aws_region
    aws_log_group   = local.cloudwatch_log_group_name
    aws_account_id  = module.common_aws-configuration.aws_account_id
    start_position  = var.csv_start_position
    interval        = var.csv_interval
    event_filter    = var.csv_event_filter
    description     = var.csv_description
    cluster_name    = var.csv_cluster_name
  })
}

module "gdp_connect-datasource-to-uc" {
  source = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  count  = var.enable_universal_connector ? 1 : 0  # Skip creation when disabled
  udc_name = local.udc_name_safe
  udc_csv_parsed = local.udc_csv
  
  # Directory configuration - pass through to child module
  profile_upload_directory = var.profile_upload_directory
  profile_api_directory    = var.profile_api_directory
  
  client_id              = var.gdp_client_id
  client_secret          = var.gdp_client_secret
  gdp_server             = var.gdp_server
  gdp_port               = var.gdp_port
  gdp_username           = var.gdp_username
  gdp_password           = var.gdp_password
  gdp_ssh_username       = var.gdp_ssh_username
  gdp_ssh_privatekeypath = var.gdp_ssh_privatekeypath
  gdp_mu_host            = var.gdp_mu_host
}

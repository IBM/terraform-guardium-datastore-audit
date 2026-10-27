#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# AWS Redshift Universal Connector Module

# Get AWS account ID automatically if not provided
data "aws_caller_identity" "current" {}

module "common_aws-configuration" {
  source  = "IBM/common/guardium//modules/aws-configuration"
  version = "= 1.6.1"
}

locals {
  # Use provided AWS account ID or get it automatically
  aws_account_id = module.common_aws-configuration.aws_account_id

  # Sanitize name_prefix for AWS resources (replace underscores with hyphens)
  sanitized_name_prefix = replace(var.name_prefix, "_", "-")

  # Resolve audit setup: enable_audit_setup is the canonical flag.
  # enable_logging and create_parameter_group are kept for backward compatibility
  # with callers that don't set enable_audit_setup (e.g. aws-redshift-with-uc).
  audit_setup_enabled = var.enable_audit_setup && var.enable_logging && var.create_parameter_group

  # CloudWatch and S3 configuration
  cloudwatch_log_group_base            = var.existing_cloudwatch_log_group_name != "" ? var.existing_cloudwatch_log_group_name : "/aws/redshift/cluster/${var.redshift_cluster_identifier}"
  cloudwatch_log_group_connectionlog   = "${local.cloudwatch_log_group_base}/connectionlog"
  cloudwatch_log_group_useractivitylog = "${local.cloudwatch_log_group_base}/useractivitylog"

  # Determine log groups (supports explicit list, comma-separated string, base path, or defaults)
  log_groups = length(var.cloudwatch_log_groups) > 0 ? join(",", var.cloudwatch_log_groups) : (
    var.existing_cloudwatch_log_group_name != "" ? (
      length(regexall(",", var.existing_cloudwatch_log_group_name)) > 0 ? var.existing_cloudwatch_log_group_name : "${var.existing_cloudwatch_log_group_name}/connectionlog,${var.existing_cloudwatch_log_group_name}/useractivitylog"
    ) : "${local.cloudwatch_log_group_connectionlog},${local.cloudwatch_log_group_useractivitylog}"
  )

  s3_bucket_name = var.existing_s3_bucket_name != "" ? var.existing_s3_bucket_name : "${local.sanitized_name_prefix}-redshift-logs"
  s3_prefix      = var.s3_prefix != "" ? var.s3_prefix : "AWSLogs/${local.aws_account_id}/redshift/${var.aws_region}/"

  # Determine if we're using existing resources
  use_existing_cloudwatch_log_group = var.existing_cloudwatch_log_group_name != "" || length(var.cloudwatch_log_groups) > 0
  use_existing_s3_bucket            = var.existing_s3_bucket_name != ""

  # Create a sanitized version of the UDC name for file paths
  default_udc_name = format("%s-%s-%s", var.aws_region, var.redshift_cluster_identifier, local.aws_account_id)
  udc_name         = var.udc_name != "" ? var.udc_name : local.default_udc_name
  udc_name_safe    = replace(local.udc_name, "/", "-")

  default_description = var.udc_description != "" ? var.udc_description : (var.csv_description != "" && var.csv_description != "Redshift Universal Connector" ? var.csv_description : "GDP AWS Redshift ${var.uc_mode} connector for ${var.redshift_cluster_identifier}")

  # Redshift CloudWatch Logstash CSV
  redshift_cloudwatch_csv = templatefile("${path.module}/templates/redshift-over-cloudwatch.tpl", {
    udc_name                      = local.udc_name_safe
    credential_name               = var.udc_aws_credential
    aws_region                    = var.aws_region
    aws_log_group_connectionlog   = local.cloudwatch_log_group_connectionlog
    aws_log_group_useractivitylog = local.cloudwatch_log_group_useractivitylog
    aws_account_id                = local.aws_account_id
    prefix                        = "false"
    start_position                = var.csv_start_position
    interval                      = var.csv_interval
    codec_pattern                 = var.codec_pattern
    event_filter                  = var.csv_event_filter
    description                   = local.default_description
    cluster_name                  = var.csv_cluster_name
    endpoint                      = var.cloudwatch_endpoint
    use_aws_bundled_ca            = var.use_aws_bundled_ca
  })

  # Redshift S3 Logstash CSV
  redshift_s3_csv = templatefile("${path.module}/templates/redshift-over-s3.tpl", {
    udc_name        = local.udc_name_safe
    credential_name = var.udc_aws_credential
    aws_region      = var.aws_region
    s3_bucket       = local.s3_bucket_name
    s3_prefix       = local.s3_prefix
    aws_account_id  = local.aws_account_id
    start_position  = var.csv_start_position
    interval        = var.csv_interval
    codec_pattern   = var.codec_pattern
    event_filter    = var.csv_event_filter
    description     = local.default_description
    cluster_name    = var.csv_cluster_name
  })

  # Redshift CloudWatch Kafka CSV (Connect 2.0)
  redshift_kafka_csv = templatefile("${path.module}/templates/redshiftKafka.tpl", {
    udc_name              = local.udc_name_safe
    description           = local.default_description
    credential_name       = var.udc_aws_credential
    cluster_name          = var.kafka_cluster_name
    use_elb               = var.use_elb
    aws_region            = var.aws_region
    aws_log_group         = local.log_groups
    filter_pattern        = var.filter_pattern
    aws_account_id        = local.aws_account_id
    database_cluster_name = var.database_cluster_name != "" ? var.database_cluster_name : var.redshift_cluster_identifier
    event_delay           = var.event_delay
    nodata_threshold_min  = var.nodata_threshold_min
    poll_interval_sec     = var.poll_interval_sec
    poll_interval         = var.poll_interval
    event_limit           = var.event_limit
    timestamp_start       = var.timestamp_start
    unmask                = var.unmask
  })

  # Generate the CSV content based on uc_mode and input_type
  udc_csv = var.uc_mode == "kafka" ? local.redshift_kafka_csv : (var.input_type == "cloudwatch" ? local.redshift_cloudwatch_csv : local.redshift_s3_csv)
}

# Data source for existing CloudWatch Log Group (legacy support)
data "aws_cloudwatch_log_group" "existing" {
  count = local.use_existing_cloudwatch_log_group && (var.uc_mode == "kafka" || var.input_type == "cloudwatch") ? 1 : 0
  name  = var.existing_cloudwatch_log_group_name != "" ? var.existing_cloudwatch_log_group_name : try(var.cloudwatch_log_groups[0], "")
}

# Data source for existing S3 bucket
data "aws_s3_bucket" "existing" {
  count  = local.use_existing_s3_bucket && var.uc_mode != "kafka" && var.input_type == "s3" ? 1 : 0
  bucket = var.existing_s3_bucket_name
}

# Create S3 bucket if needed
resource "aws_s3_bucket" "redshift_logs" {
  count         = var.uc_mode != "kafka" && var.input_type == "s3" && !local.use_existing_s3_bucket ? 1 : 0
  bucket        = local.s3_bucket_name
  force_destroy = true
  tags          = var.tags
}

# Create CloudWatch Log Groups if needed (one for connectionlog, one for useractivitylog)
# Note: If these already exist (created by Redshift), import them or set existing_cloudwatch_log_group_name / cloudwatch_log_groups
resource "aws_cloudwatch_log_group" "redshift_connectionlog" {
  count = (var.uc_mode == "kafka" || var.input_type == "cloudwatch") && !local.use_existing_cloudwatch_log_group ? 1 : 0
  name  = local.cloudwatch_log_group_connectionlog
  tags  = var.tags
}

resource "aws_cloudwatch_log_group" "redshift_useractivitylog" {
  count = (var.uc_mode == "kafka" || var.input_type == "cloudwatch") && !local.use_existing_cloudwatch_log_group ? 1 : 0
  name  = local.cloudwatch_log_group_useractivitylog
  tags  = var.tags
}

# Configure Redshift to export logs to CloudWatch or S3
resource "aws_redshift_parameter_group" "redshift_logging" {
  count  = local.audit_setup_enabled ? 1 : 0
  name   = "${local.sanitized_name_prefix}-redshift-logging"
  family = "redshift-1.0"

  parameter {
    name  = "enable_user_activity_logging"
    value = "true"
  }

  tags = var.tags
}

# Apply parameter group to cluster
resource "null_resource" "apply_parameter_group" {
  count = local.audit_setup_enabled ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      aws redshift modify-cluster-parameter-group \
        --parameter-group-name ${var.existing_parameter_group_name != "" ? var.existing_parameter_group_name : aws_redshift_parameter_group.redshift_logging[0].name} \
        --parameters ParameterName=enable_user_activity_logging,ParameterValue=true \
        --region ${var.aws_region}
      
      # Wait for the cluster to finish modifying
      echo "Waiting for Redshift cluster to finish modifying..."
      aws redshift wait cluster-available \
        --cluster-identifier ${var.redshift_cluster_identifier} \
        --region ${var.aws_region}
    EOT
  }

  depends_on = [aws_redshift_parameter_group.redshift_logging]
}

# Configure logging using null_resource
resource "null_resource" "configure_logging" {
  count = local.audit_setup_enabled ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      if [ "${var.uc_mode}" = "kafka" ] || [ "${var.input_type}" = "cloudwatch" ]; then
        aws redshift enable-logging \
          --cluster-identifier ${var.redshift_cluster_identifier} \
          --log-destination-type cloudwatch \
          --log-exports "connectionlog" "useractivitylog" \
          --region ${var.aws_region}
      else
        aws redshift enable-logging \
          --cluster-identifier ${var.redshift_cluster_identifier} \
          --bucket-name ${local.s3_bucket_name} \
          --s3-key-prefix ${local.s3_prefix} \
          --region ${var.aws_region}
      fi
    EOT
  }

  depends_on = [null_resource.apply_parameter_group]
}

# Universal Connector module
module "gdp_connect-datasource-to-uc" {
  source           = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  version          = "= 1.3.3"
  count            = var.enable_universal_connector ? 1 : 0 # Skip creation when disabled
  udc_name         = local.udc_name_safe
  udc_csv_parsed   = local.udc_csv
  client_id        = var.gdp_client_id
  client_secret    = var.gdp_client_secret
  gdp_server       = var.gdp_server
  gdp_port         = var.gdp_port
  gdp_username     = var.gdp_username
  gdp_password     = var.gdp_password
  gdp_mu_host      = var.gdp_mu_host
  test_connections = var.uc_mode == "kafka" ? true : false

  depends_on = [
    null_resource.configure_logging
  ]
}

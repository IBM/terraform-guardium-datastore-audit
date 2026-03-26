#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# AWS S3 Audit Example

module "datastore-audit_aws-s3" {
  source = "../../modules/aws-s3"

  # General Configuration
  name_prefix = var.name_prefix
  aws_region  = var.aws_region
  tags        = var.tags

  # CloudTrail Configuration
  enable_cloudtrail                  = var.enable_cloudtrail
  existing_cloudtrail_name           = var.existing_cloudtrail_name
  existing_cloudwatch_log_group_name = var.existing_cloudwatch_log_group_name
  force_destroy_bucket               = var.force_destroy_bucket
  cloudwatch_logs_retention_days     = var.cloudwatch_logs_retention_days
  
  # S3 Buckets to Monitor
  s3_bucket_arns = var.s3_bucket_arns
  
  # CloudTrail Settings
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  include_management_events     = var.include_management_events

  # Guardium Data Protection Configuration
  gdp_server        = var.gdp_server
  gdp_port          = var.gdp_port
  gdp_username      = var.gdp_username
  gdp_password      = var.gdp_password
  gdp_client_id     = var.gdp_client_id
  gdp_client_secret = var.gdp_client_secret
  gdp_mu_host       = var.gdp_mu_host

  # Universal Connector Configuration
  enable_universal_connector = var.enable_universal_connector
  udc_aws_credential         = var.udc_aws_credential
  udc_start_position         = var.udc_start_position
  udc_interval               = var.udc_interval
  udc_event_filter           = var.udc_event_filter
  udc_description            = var.udc_description
  udc_prefix                 = var.udc_prefix
  udc_unmask                 = var.udc_unmask
  udc_endpoint               = var.udc_endpoint
  udc_use_aws_bundled_ca     = var.udc_use_aws_bundled_ca
}
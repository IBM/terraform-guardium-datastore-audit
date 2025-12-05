#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# AWS Redshift with Universal Connector Example

#----------------------------------------
# No Provider Configuration Here
# Providers are configured in provider.tf
#----------------------------------------

#----------------------------------------
# Redshift Universal Connector Configuration
#----------------------------------------
module "datastore-audit_aws-redshift" {
  source = "../../modules/aws-redshift"

  # General Configuration
  name_prefix = var.name_prefix
  aws_region  = var.aws_region
  tags        = var.tags

  # Redshift Configuration
  redshift_cluster_identifier = var.redshift_cluster_identifier

  # Input Configuration
  input_type = var.input_type

  # CloudWatch Configuration
  existing_cloudwatch_log_group_name = var.existing_cloudwatch_log_group_name

  # S3 Configuration
  existing_s3_bucket_name = var.existing_s3_bucket_name
  s3_prefix               = var.s3_prefix

  # Parameter Group Configuration
  create_parameter_group = var.create_parameter_group
  existing_parameter_group_name = var.existing_parameter_group_name
  enable_logging = var.enable_logging

  # Guardium Data Protection Configuration
  gdp_server             = var.gdp_server
  gdp_port               = var.gdp_port
  gdp_username           = var.gdp_username
  gdp_password           = var.gdp_password
  gdp_client_id          = var.gdp_client_id
  gdp_client_secret      = var.gdp_client_secret
  gdp_ssh_username       = var.gdp_ssh_username
  gdp_ssh_privatekeypath = var.gdp_ssh_privatekeypath
  gdp_mu_host            = var.gdp_mu_host

  # Universal Connector Configuration
  enable_universal_connector = var.enable_universal_connector
  udc_aws_credential        = var.udc_aws_credential
  csv_start_position        = var.csv_start_position
  csv_interval              = var.csv_interval
  codec_pattern             = var.codec_pattern
  csv_event_filter          = var.csv_event_filter
  csv_description           = var.csv_description
  csv_cluster_name          = var.csv_cluster_name
  
  # Directory Configuration
  profile_upload_directory = var.profile_upload_directory
  profile_api_directory    = var.profile_api_directory
  use_multipart_upload     = var.use_multipart_upload
}
# AWS DynamoDB with Universal Connector Example

#----------------------------------------
# No Provider Configuration Here
# Providers are configured in provider.tf
#----------------------------------------

#----------------------------------------
# DynamoDB Universal Connector Configuration
#----------------------------------------
module "datastore-audit_aws-dynamodb" {
  source = "../../modules/aws-dynamodb"

  # AWS Configuration
  aws_region     = var.aws_region
  aws_partition  = var.aws_partition
  name_prefix    = var.name_prefix
  tags           = var.tags

  # DynamoDB Tables Configuration
  dynamodb_tables = var.dynamodb_tables

  # CloudTrail and CloudWatch Configuration
  existing_cloudtrail_name         = var.existing_cloudtrail_name
  existing_cloudwatch_log_group_name = var.existing_cloudwatch_log_group_name

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
  udc_aws_credential         = var.udc_aws_credential
  enable_universal_connector = var.enable_universal_connector
  profile_upload_directory   = var.profile_upload_directory
  profile_api_directory      = var.profile_api_directory
  use_multipart_upload       = var.use_multipart_upload

  # CSV Configuration
  csv_start_position     = var.csv_start_position
  csv_interval           = var.csv_interval
  csv_event_filter       = var.csv_event_filter
  csv_description        = var.csv_description
  csv_cluster_name       = var.csv_cluster_name
}

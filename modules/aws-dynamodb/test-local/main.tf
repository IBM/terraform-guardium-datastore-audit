# Test configuration to verify CloudWatch Log Group fix
# This uses the aws-dynamodb module with the fix applied

module "test_dynamodb" {
  source = "../"  # Points to the parent directory (aws-dynamodb module)

  # AWS Configuration
  aws_region    = var.aws_region
  aws_partition = var.aws_partition
  name_prefix   = var.name_prefix
  tags          = var.tags

  # DynamoDB Tables Configuration
  dynamodb_tables = var.dynamodb_tables

  # CloudWatch Log Group Configuration
  # Leave empty to test auto-detection
  existing_cloudwatch_log_group_name = var.existing_cloudwatch_log_group_name
  existing_cloudtrail_name           = var.existing_cloudtrail_name

  # Guardium Data Protection Configuration
  gdp_server        = var.gdp_server
  gdp_port          = var.gdp_port
  gdp_username      = var.gdp_username
  gdp_password      = var.gdp_password
  gdp_client_id     = var.gdp_client_id
  gdp_client_secret = var.gdp_client_secret
  gdp_mu_host       = var.gdp_mu_host

  # Universal Connector Configuration
  udc_aws_credential         = var.udc_aws_credential
  enable_universal_connector = var.enable_universal_connector
  csv_start_position         = var.csv_start_position
  csv_interval               = var.csv_interval
  csv_event_filter           = var.csv_event_filter
  csv_description            = var.csv_description
  csv_cluster_name           = var.csv_cluster_name
}

# Output to verify the detection logic
output "log_group_name" {
  description = "The CloudWatch Log Group name being used"
  value       = module.test_dynamodb.cloudwatch_log_group_name
}

output "log_group_arn" {
  description = "The CloudWatch Log Group ARN"
  value       = module.test_dynamodb.cloudwatch_log_group_arn
}
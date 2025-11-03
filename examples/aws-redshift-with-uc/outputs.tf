# AWS Redshift with Universal Connector Example Outputs

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = module.datastore-audit_aws-redshift.udc_name
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = module.datastore-audit_aws-redshift.cloudwatch_log_group_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.datastore-audit_aws-redshift.s3_bucket_name
}

output "s3_prefix" {
  description = "Prefix for S3 objects"
  value       = module.datastore-audit_aws-redshift.s3_prefix
}

output "parameter_group_name" {
  description = "Name of the Redshift parameter group"
  value       = module.datastore-audit_aws-redshift.parameter_group_name
}

output "input_type" {
  description = "Type of input for the Universal Connector"
  value       = module.datastore-audit_aws-redshift.input_type
}
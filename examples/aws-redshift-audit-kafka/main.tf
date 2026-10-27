#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

/**
 * # AWS Redshift with Universal Connector (Kafka, Connect 2.0)
 *
 * This example configures IBM Guardium Data Protection to collect AWS Redshift audit logs
 * through the "AWS Redshift Over Cloudwatch Connect 2.0" Kafka-based Universal Connector profile.
 *
 * Audit setup (parameter group + CloudWatch log exports) is not managed by this example.
 * Ensure your Redshift cluster already has user activity logging enabled and is exporting
 * logs to CloudWatch before applying this configuration.
 */

provider "aws" {
  region = var.aws_region
}

module "datastore-audit_aws-redshift-audit-kafka" {
  source = "../../modules/aws-redshift"

  # General Configuration
  name_prefix = var.name_prefix
  aws_region  = var.aws_region
  tags        = var.tags
  uc_mode     = "kafka"

  # Redshift Configuration
  redshift_cluster_identifier        = var.redshift_cluster_identifier
  existing_cloudwatch_log_group_name = var.existing_cloudwatch_log_group_name
  cloudwatch_log_groups              = var.cloudwatch_log_groups
  enable_audit_setup = false

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
  udc_name                   = var.udc_name
  udc_description            = var.udc_description

  # Kafka-specific Configuration
  kafka_cluster_name    = var.kafka_cluster_name
  use_elb               = var.use_elb
  filter_pattern        = var.filter_pattern
  database_cluster_name = var.database_cluster_name
  event_delay           = var.event_delay
  nodata_threshold_min  = var.nodata_threshold_min
  poll_interval_sec     = var.poll_interval_sec
  poll_interval         = var.poll_interval
  event_limit           = var.event_limit
  timestamp_start       = var.timestamp_start
  unmask                = var.unmask
}

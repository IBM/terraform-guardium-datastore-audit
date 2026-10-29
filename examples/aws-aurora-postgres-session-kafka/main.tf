#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

/**
 * # AWS Aurora PostgreSQL with Universal Connector - Session Auditing (Kafka)
 *
 * This example demonstrates how to configure AWS Aurora PostgreSQL with Guardium Universal Connector
 * using session-level auditing and a Kafka-based Universal Connector.
 *
 * ## Usage
 *
 * Session-level auditing monitors all database activity for the entire session.
 * Configure the `pg_audit_log` variable to specify what types of statements to audit.
 * This variant uses a Kafka-based UC instead of CloudWatch/SQS polling.
 */

# Configure AWS provider
provider "aws" {
  region = var.aws_region
}

# Configure Guardium Data Protection provider
provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}

module "aurora_postgres_session_audit_kafka" {
  source = "../../modules/aws-aurora-postgres-session"

  # AWS configuration
  aws_region                         = var.aws_region
  aurora_postgres_cluster_identifier = var.aurora_postgres_cluster_identifier
  tags                               = var.tags
  force_failover                     = var.force_failover
  skip_reboot                        = var.skip_reboot
  pg_audit_log                       = var.pg_audit_log

  # Guardium configuration
  udc_name           = var.udc_name
  udc_aws_credential = var.udc_aws_credential
  gdp_client_secret  = var.gdp_client_secret
  gdp_client_id      = var.gdp_client_id
  gdp_server         = var.gdp_server
  gdp_port           = var.gdp_port
  gdp_username       = var.gdp_username
  gdp_password       = var.gdp_password
  gdp_mu_host        = var.gdp_mu_host

  # Audit setup control
  enable_audit_setup = var.enable_audit_setup

  # Universal Connector configuration
  enable_universal_connector = var.enable_universal_connector
  uc_mode                    = "kafka"

  # Kafka-specific configuration
  kafka_cluster_name   = var.kafka_cluster_name
  use_elb              = var.use_elb
  event_delay          = var.event_delay
  nodata_threshold_min = var.nodata_threshold_min
  unmask               = var.unmask
  filter_pattern       = var.filter_pattern
  poll_interval_sec    = var.poll_interval_sec
  poll_interval        = var.poll_interval
  event_limit          = var.event_limit
  timestamp_start      = var.timestamp_start
}

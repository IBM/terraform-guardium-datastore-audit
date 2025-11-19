#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

/**
 * # AWS Aurora PostgreSQL with Universal Connector - Session Auditing
 *
 * This example demonstrates how to configure AWS Aurora PostgreSQL with Guardium Universal Connector
 * using session-level auditing.
 *
 * ## Usage
 *
 * Session-level auditing monitors all database activity for the entire session.
 * Configure the `pg_audit_log` variable to specify what types of statements to audit.
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

module "aurora_postgres_session_audit" {
  source = "../../modules/aws-aurora-postgres-session"

  # AWS configuration
  aws_region                     = var.aws_region
  aurora_postgres_cluster_identifier = var.aurora_postgres_cluster_identifier
  force_failover                 = var.force_failover
  pg_audit_log                   = var.pg_audit_log

  # Guardium configuration
  udc_name                       = var.udc_name
  udc_aws_credential             = var.udc_aws_credential
  gdp_client_secret              = var.gdp_client_secret
  gdp_client_id                  = var.gdp_client_id
  gdp_server                     = var.gdp_server
  gdp_port                       = var.gdp_port
  gdp_username                   = var.gdp_username
  gdp_password                   = var.gdp_password
  gdp_ssh_username               = var.gdp_ssh_username
  gdp_ssh_privatekeypath         = var.gdp_ssh_privatekeypath
  gdp_mu_host                    = var.gdp_mu_host

  # Universal Connector configuration
  enable_universal_connector     = var.enable_universal_connector
  csv_start_position             = var.csv_start_position
  csv_interval                   = var.csv_interval
  csv_event_filter               = var.csv_event_filter
  log_export_type                = var.log_export_type
}
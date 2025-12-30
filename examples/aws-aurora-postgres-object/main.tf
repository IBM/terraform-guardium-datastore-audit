#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

/**
 * # AWS Aurora PostgreSQL with Universal Connector - Object Auditing
 *
 * This example demonstrates how to configure AWS Aurora PostgreSQL with Guardium Universal Connector
 * using object-level auditing.
 *
 * ## Usage
 *
 * Object-level auditing allows you to monitor specific tables with granular permissions.
 * Configure the `tables` variable to specify which tables to monitor and what permissions to audit.
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

module "aurora_postgres_object_audit" {
  source = "../../modules/aws-aurora-postgres-object"

  # AWS Configuration
  aws_region     = var.aws_region
  aurora_postgres_cluster_identifier = var.aurora_postgres_cluster_identifier
  tags           = var.tags

  # Database Connection Configuration
  db_host     = var.db_host
  db_port     = var.db_port
  db_username = var.db_username
  db_password = var.db_password
  db_name     = var.db_name
  
  # Audit Configuration
  force_failover = var.force_failover
  tables         = var.tables
  
  # Guardium Data Protection Configuration
  gdp_server             = var.gdp_server
  gdp_port               = var.gdp_port
  gdp_username           = var.gdp_username
  gdp_password           = var.gdp_password
  gdp_client_id          = var.gdp_client_id
  gdp_client_secret      = var.gdp_client_secret
  gdp_mu_host            = var.gdp_mu_host
  
  # Universal Connector Configuration
  udc_aws_credential     = var.udc_aws_credential
  enable_universal_connector = var.enable_universal_connector
  
  # Log Export Configuration
  log_export_type = var.log_export_type
  
  # CSV Configuration
  csv_start_position     = var.csv_start_position
  csv_interval           = var.csv_interval
  csv_event_filter       = var.csv_event_filter
}
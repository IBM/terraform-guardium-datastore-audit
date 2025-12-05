/**
 * # AWS RDS PostgreSQL with Universal Connector
 *
 * This example demonstrates how to configure AWS RDS PostgreSQL with Guardium Universal Connector
 * using either object-level or session-level auditing.
 *
 * ## Usage
 *
 * Set the `audit_type` variable to either "object" or "session" to choose the auditing approach:
 * - "object": Uses object-level auditing with table-specific grants
 * - "session": Uses session-level auditing for all database activity
 */

# Configure AWS provider
provider "aws" {
  region = var.aws_region
}

module "datastore-audit_aws-postgresql-rds-object" {
  source = "../../modules/aws-postgresql-rds-object"

  # AWS configuration
  aws_region                     = var.aws_region
  postgres_rds_cluster_identifier = var.postgres_rds_cluster_identifier
  force_failover                 = var.force_failover

  # Database connection details
  db_host                        = var.db_host
  db_port                        = var.db_port
  db_username                    = var.db_username
  db_password                    = var.db_password
  db_name                        = var.db_name
  ssl_mode = var.ssl_mode

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
  profile_upload_directory       = var.profile_upload_directory
  profile_api_directory          = var.profile_api_directory
  use_multipart_upload           = var.use_multipart_upload

  tables                         =  var.tables
}

#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}

module "datastore-audit_onprem-couchbase" {
  source = "../../modules/onprem-couchbase"

  # Couchbase Instance Configuration
  couchbase_instance_identifier = var.couchbase_instance_identifier
  couchbase_host                = var.couchbase_host
  couchbase_port                = var.couchbase_port
  couchbase_cluster_name        = var.couchbase_cluster_name
  couchbase_admin_username      = var.couchbase_admin_username
  couchbase_admin_password      = var.couchbase_admin_password
  couchbase_audit_log_directory = var.couchbase_audit_log_directory
  logstash_port                 = var.logstash_port
  datasource_tag                = var.datasource_tag

  # Audit Configuration
  enable_audit_logging      = var.enable_audit_logging
  audit_log_rotate_interval = var.audit_log_rotate_interval
  audit_log_rotate_size     = var.audit_log_rotate_size

  # Filebeat Setup Configuration
  enable_filebeat_setup = var.enable_filebeat_setup
  server_ip             = var.server_ip
  server_username       = var.server_username
  server_password       = var.server_password

  # Guardium Configuration
  udc_name          = var.udc_name
  gdp_client_id     = var.gdp_client_id
  gdp_client_secret = var.gdp_client_secret
  gdp_server        = var.gdp_server
  gdp_port          = var.gdp_port
  gdp_username      = var.gdp_username
  gdp_password      = var.gdp_password
  gdp_mu_host       = var.gdp_mu_host

  # Universal Connector Configuration
  enable_universal_connector = var.enable_universal_connector

  # CSV Configuration
  csv_description = var.csv_description

  # Tags
  tags = var.tags
}
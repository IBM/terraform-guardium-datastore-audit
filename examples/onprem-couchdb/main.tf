#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

provider "gdp-middleware-helper" {}

provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}

module "datastore-audit_onprem-couchdb" {
  source = "../../modules/onprem-couchdb"

  # CouchDB Instance Configuration
  couchdb_instance_identifier = var.couchdb_instance_identifier
  couchdb_host                = var.couchdb_host
  couchdb_audit_log_path      = var.couchdb_audit_log_path
  datasource_tag              = var.datasource_tag
  logstash_port               = var.logstash_port

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

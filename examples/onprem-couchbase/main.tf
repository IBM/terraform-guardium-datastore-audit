#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}

provider "gdp-middleware-helper" {
  # Provider configuration for gdp-middleware-helper
  # This provider is used to configure Filebeat on remote servers
}

module "datastore-audit_onprem-couchbase" {
  source = "../../modules/onprem-couchbase"

  # Couchbase Instance Configuration
  couchbase_cluster_name   = var.couchbase_cluster_name
  couchbase_host           = var.couchbase_host
  couchbase_admin_port     = var.couchbase_admin_port
  couchbase_admin_username = var.couchbase_admin_username
  couchbase_admin_password = var.couchbase_admin_password
  couchbase_audit_log_path = var.couchbase_audit_log_path

  # Audit Configuration
  enable_audit_log = var.enable_audit_log
  enable_filebeat  = var.enable_filebeat

  # Server Connection Configuration
  server_ip       = var.server_ip
  server_username = var.server_username
  server_password = var.server_password
  ssh_port        = var.ssh_port

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

  # Filebeat/Logstash Configuration
  logstash_port                      = var.logstash_port
  ssl_enable                         = var.ssl_enable
  ssl_verify                         = var.ssl_verify
  ssl_cert_path                      = var.ssl_cert_path
  ssl_certificate_authority_filename = var.ssl_certificate_authority_filename

  # CSV Configuration
  csv_description = var.csv_description

  # Tags
  tags = var.tags
}

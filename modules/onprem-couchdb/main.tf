#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

# On-Premises CouchDB Audit Configuration Module
# This module configures Filebeat to collect CouchDB audit logs and forward them to Guardium

# Configure Filebeat using gdp-middleware-helper provider
resource "gdp-middleware-helper_filebeat_configure" "couchdb" {
  count = var.enable_filebeat_setup ? 1 : 0

  host           = var.server_ip
  username       = var.server_username
  password       = var.server_password
  audit_log_path = var.couchdb_audit_log_path
  datasource_tag = var.datasource_tag
  logstash_host  = var.gdp_mu_host
  logstash_port  = var.logstash_port
}

locals {
  udc_name = var.udc_name != "" ? var.udc_name : format("onprem-couchdb-%s", var.couchdb_instance_identifier)
}

# Generate the CSV content from the template
locals {
  onprem_couchdb_csv = templatefile("${path.module}/templates/onprem-couchdb.tpl", {
    udc_name       = local.udc_name
    description    = var.csv_description != "" ? var.csv_description : "GDP On-Premises CouchDB connector for ${var.couchdb_instance_identifier}"
    datasource_tag = var.datasource_tag
    port           = var.logstash_port
  })
}

# Connect datasource to Guardium Universal Connector
module "gdp_connect-datasource-to-uc" {
  source         = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  count          = var.enable_universal_connector ? 1 : 0
  udc_name       = local.udc_name
  udc_csv_parsed = local.onprem_couchdb_csv

  # Guardium configuration
  client_id     = var.gdp_client_id
  client_secret = var.gdp_client_secret
  gdp_server    = var.gdp_server
  gdp_port      = var.gdp_port
  gdp_username  = var.gdp_username
  gdp_password  = var.gdp_password
  gdp_mu_host   = var.gdp_mu_host

  # Wait for Filebeat setup to complete before creating connector
  depends_on = [gdp-middleware-helper_filebeat_configure.couchdb]
}

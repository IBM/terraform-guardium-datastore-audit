#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

provider "gdp-middleware-helper" {}

provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}

module "datastore-audit_onprem-mysql" {
  source = "../../modules/onprem-mysql"

  # MySQL Instance Configuration
  mysql_instance_identifier          = var.mysql_instance_identifier
  syslog_port                        = var.syslog_port
  mysql_host                         = var.mysql_host
  ssl_certificate_authority_filename = var.ssl_certificate_authority_filename

  # Audit Configuration
  enable_audit_log = var.enable_audit_log

  # Server Connection Configuration (Linux)
  server_ip           = var.server_ip
  server_username     = var.server_username
  server_password     = var.server_password
  mysql_root_password = var.mysql_root_password
  mysql_install_path  = var.mysql_install_path

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

  # Syslog Configuration
  ssl_enable = var.ssl_enable
  ssl_verify = var.ssl_verify

  # Tags
  tags = var.tags
}

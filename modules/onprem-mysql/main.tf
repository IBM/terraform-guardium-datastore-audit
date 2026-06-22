#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

# Configure MySQL audit logging using gdp-middleware-helper provider
resource "gdp-middleware-helper_mysql_audit_configure" "mysql" {
  count = var.enable_audit_log ? 1 : 0

  host                = var.server_ip
  username            = var.server_username
  password            = var.server_password
  mysql_root_password = var.mysql_root_password
  mysql_install_path  = var.mysql_install_path
  logstash_host       = var.gdp_mu_host
  logstash_port       = var.syslog_port
}

locals {
  udc_name = var.udc_name != "" ? var.udc_name : format("onprem-mysql-%s", var.mysql_instance_identifier)
}

# Generate the CSV content from the template
locals {
  onprem_mysql_csv = templatefile("${path.module}/templates/onprem-mysql.tpl", {
    udc_name                           = local.udc_name
    syslog_port                        = var.syslog_port
    ssl_enable                         = var.ssl_enable
    ssl_verify                         = var.ssl_verify
    description                        = "GDP On-Premises MySQL connector for ${var.mysql_instance_identifier}"
    ssl_certificate_authority_filename = var.ssl_certificate_authority_filename
  })
}

# resource "local_file" "onprem_mysql_csv" {
#   content  = local.onprem_mysql_csv
#   filename = "${path.module}/output/onprem_mysql.csv"
# }

module "gdp_connect-datasource-to-uc" {
  source         = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  count          = var.enable_universal_connector ? 1 : 0
  udc_name       = local.udc_name
  udc_csv_parsed = local.onprem_mysql_csv

  # Guardium configuration
  client_id     = var.gdp_client_id
  client_secret = var.gdp_client_secret
  gdp_server    = var.gdp_server
  gdp_port      = var.gdp_port
  gdp_username  = var.gdp_username
  gdp_password  = var.gdp_password
  gdp_mu_host   = var.gdp_mu_host

  # Wait for audit setup to complete before creating connector
  depends_on = [gdp-middleware-helper_mysql_audit_configure.mysql]
}

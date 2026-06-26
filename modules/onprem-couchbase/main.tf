#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

# On-Premises Couchbase Audit Configuration Module
# This module configures Filebeat to collect Couchbase audit logs and forward them to Guardium

# Configure Couchbase audit logging via REST API (no SSH required)
resource "null_resource" "couchbase_audit_config" {
  count = var.enable_audit_log ? 1 : 0

  triggers = {
    couchbase_host         = var.couchbase_host
    couchbase_cluster_name = var.couchbase_cluster_name
    audit_log_path         = var.couchbase_audit_log_path
  }

  provisioner "local-exec" {
    command = <<-EOT
      curl -X POST http://${var.couchbase_host}:${var.couchbase_admin_port}/settings/audit \
        -u ${var.couchbase_admin_username}:${var.couchbase_admin_password} \
        -d auditdEnabled=true \
        -d rotateInterval=86400 \
        -d logPath=${dirname(var.couchbase_audit_log_path)} && \
      sleep 2 && \
      curl -X GET http://${var.couchbase_host}:${var.couchbase_admin_port}/settings/audit \
        -u ${var.couchbase_admin_username}:${var.couchbase_admin_password}
    EOT

    on_failure = continue
  }
}

# Configure Filebeat to collect and forward Couchbase audit logs using gdp-middleware-helper
resource "gdp-middleware-helper_filebeat_configure" "couchbase_filebeat" {
  count = var.enable_filebeat ? 1 : 0

  host           = var.server_ip
  port           = var.ssh_port
  username       = var.server_username
  password       = var.server_password
  audit_log_path = var.couchbase_audit_log_path
  datasource_tag = "couchbasedb"
  logstash_host  = var.gdp_mu_host
  logstash_port  = var.logstash_port

  depends_on = [null_resource.couchbase_audit_config]
}

locals {
  udc_name = var.udc_name != "" ? var.udc_name : format("onprem-couchbase-%s", var.couchbase_cluster_name)
}

# Generate the CSV content from the template
locals {
  onprem_couchbase_csv = templatefile("${path.module}/templates/onprem-couchbase.tpl", {
    udc_name                           = local.udc_name
    logstash_port                      = var.logstash_port
    ssl_enable                         = var.ssl_enable
    ssl_verify                         = var.ssl_verify
    description                        = var.csv_description != "" ? var.csv_description : "GDP On-Premises Couchbase connector for ${var.couchbase_cluster_name}"
    ssl_certificate_authority_filename = var.ssl_certificate_authority_filename
  })
}

# Connect datasource to Guardium Universal Connector
module "gdp_connect-datasource-to-uc" {
  source         = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  count          = var.enable_universal_connector ? 1 : 0
  udc_name       = local.udc_name
  udc_csv_parsed = local.onprem_couchbase_csv

  # Guardium configuration
  client_id     = var.gdp_client_id
  client_secret = var.gdp_client_secret
  gdp_server    = var.gdp_server
  gdp_port      = var.gdp_port
  gdp_username  = var.gdp_username
  gdp_password  = var.gdp_password
  gdp_mu_host   = var.gdp_mu_host

  # Wait for Filebeat setup to complete before creating connector
  depends_on = [gdp-middleware-helper_filebeat_configure.couchbase_filebeat]
}

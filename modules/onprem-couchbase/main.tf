#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

# Couchbase Audit Configuration Module
# This module configures Filebeat to forward Couchbase audit logs to Guardium
# and optionally enables audit logging on the Couchbase server

locals {
  # Commands to enable Couchbase audit logging via REST API
  enable_audit_commands = [
    # Enable audit logging with configuration
    "curl -X POST http://${var.couchbase_host}:${var.couchbase_port}/settings/audit -u ${var.couchbase_admin_username}:${var.couchbase_admin_password} -d 'auditdEnabled=true&logPath=${var.couchbase_audit_log_directory}&rotateInterval=${var.audit_log_rotate_interval}&rotateSize=${var.audit_log_rotate_size}'",
    # Enable Data Service audit events (excluding select bucket to avoid extraneous logs)
    "curl -X POST http://${var.couchbase_host}:${var.couchbase_port}/settings/audit -u ${var.couchbase_admin_username}:${var.couchbase_admin_password} -d 'disabled=8243,8255'",
    # Enable Query and Index Service audit events (excluding /admin/stats API)
    "curl -X POST http://${var.couchbase_host}:${var.couchbase_port}/settings/audit -u ${var.couchbase_admin_username}:${var.couchbase_admin_password} -d 'disabledUsers='",
    # Verify audit configuration
    "curl -X GET http://${var.couchbase_host}:${var.couchbase_port}/settings/audit -u ${var.couchbase_admin_username}:${var.couchbase_admin_password}"
  ]

  # Commands to configure Filebeat on the Couchbase server
  filebeat_commands = [
    # Backup existing filebeat.yml if it exists
    "sudo test -f /etc/filebeat/filebeat.yml && sudo cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.backup || true",
    # Create Filebeat configuration for Couchbase audit logs
    "sudo bash -c 'cat > /etc/filebeat/filebeat.yml << \"EOF\"\nfilebeat.inputs:\n- type: filestream\n  id: couchbase-audit\n  enabled: true\n  paths:\n    - ${var.couchbase_audit_log_directory}/audit.log\n  tags: [\"${var.datasource_tag}\"]\n\n  # JSON parsing for Couchbase audit logs\n  parsers:\n    - ndjson:\n        target: \"\"\n        overwrite_keys: true\n        add_error_key: true\n\n  # Fields to add to each event\n  fields:\n    log_type: couchbase_audit\n    couchbase_cluster: ${var.couchbase_cluster_name}\n\n  # Multiline settings for handling log rotation\n  multiline.type: pattern\n  multiline.pattern: '^\\{'\n  multiline.negate: true\n  multiline.match: after\n\n# Output to Guardium Universal Connector\noutput.logstash:\n  hosts: [\"${var.gdp_mu_host}:${var.logstash_port}\"]\n\n# Logging configuration\nlogging.level: info\nlogging.to_files: true\nlogging.files:\n  path: /var/log/filebeat\n  name: filebeat\n  keepfiles: 7\n  permissions: 0644\n\nlogging.level: debug\nlogging.selectors: [\"*\"]\nEOF\n'",
    # Test Filebeat configuration
    "sudo filebeat test config -c /etc/filebeat/filebeat.yml",
    # Restart Filebeat service
    "sudo systemctl restart filebeat",
    # Enable Filebeat to start on boot
    "sudo systemctl enable filebeat",
    # Verify Filebeat is running
    "sudo systemctl status filebeat --no-pager"
  ]
}

# Enable Couchbase audit logging
resource "null_resource" "couchbase_enable_audit" {
  count = var.enable_audit_logging ? 1 : 0

  # Triggers to force recreation when critical variables change
  triggers = {
    couchbase_host                 = var.couchbase_host
    couchbase_port                 = var.couchbase_port
    couchbase_audit_log_directory  = var.couchbase_audit_log_directory
    audit_log_rotate_interval      = var.audit_log_rotate_interval
    audit_log_rotate_size          = var.audit_log_rotate_size
  }

  # SSH connection to Couchbase server
  connection {
    type     = "ssh"
    host     = var.server_ip
    user     = var.server_username
    password = var.server_password
    timeout  = "10m"
  }

  provisioner "remote-exec" {
    inline = local.enable_audit_commands
  }
}

# Configure Filebeat on Couchbase server
resource "null_resource" "couchbase_filebeat_setup" {
  count = var.enable_filebeat_setup ? 1 : 0

  # Triggers to force recreation when critical variables change
  triggers = {
    server_ip                     = var.server_ip
    couchbase_audit_log_directory = var.couchbase_audit_log_directory
    gdp_mu_host                   = var.gdp_mu_host
    logstash_port                 = var.logstash_port
    datasource_tag                = var.datasource_tag
    couchbase_cluster_name        = var.couchbase_cluster_name
  }

  # SSH connection to Couchbase server
  connection {
    type     = "ssh"
    host     = var.server_ip
    user     = var.server_username
    password = var.server_password
    timeout  = "10m"
  }

  provisioner "remote-exec" {
    inline = local.filebeat_commands
  }

  # Wait for audit logging to be enabled first
  depends_on = [null_resource.couchbase_enable_audit]
}

locals {
  udc_name = var.udc_name != "" ? var.udc_name : format("onprem-couchbase-%s", var.couchbase_instance_identifier)
}

# Generate the CSV content from the template
locals {
  onprem_couchbase_csv = templatefile("${path.module}/templates/onprem-couchbase.tpl", {
    udc_name       = local.udc_name
    description    = var.csv_description != "" ? var.csv_description : "GDP On-Premises Couchbase connector for ${var.couchbase_instance_identifier}"
    datasource_tag = var.datasource_tag
    port           = var.logstash_port
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
  depends_on = [null_resource.couchbase_filebeat_setup]
}
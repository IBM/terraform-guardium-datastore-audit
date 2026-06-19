#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

# On-Premises Couchbase Audit Configuration Module
# This module configures Filebeat to collect Couchbase audit logs and forward them to Guardium

locals {
  # Build SSL configuration conditionally
  ssl_config = var.ssl_enable ? "  ssl.enabled: true\n  ssl.verification_mode: ${var.ssl_verify ? "full" : "none"}\n  ssl.certificate_authorities: [\"${var.ssl_cert_path}\"]" : ""

  # Commands to configure Filebeat on the Couchbase server
  filebeat_commands = [
    # Backup existing filebeat.yml if it exists
    "sudo test -f /etc/filebeat/filebeat.yml && sudo cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.backup.$(date +%Y%m%d_%H%M%S) || true",
    # Create Filebeat configuration for Couchbase audit logs
    "sudo bash -c 'cat > /etc/filebeat/filebeat.yml << \"EOF\"\nfilebeat.inputs:\n- type: log\n  enabled: true\n  paths:\n    - ${var.couchbase_audit_log_path}\n  tags: [\"couchbasedb\"]\n\nfilebeat.config.modules:\n  path: $${path.config}/modules.d/*.yml\n  reload.enabled: false\n\nsetup.template.settings:\n  index.number_of_shards: 1\n\nsetup.kibana:\n\noutput.logstash:\n  hosts: [\"${var.gdp_mu_host}:${var.logstash_port}\"]\n${local.ssl_config}\n\nprocessors:\n  - add_host_metadata:\n      when.not.contains.tags: forwarded\n  - add_cloud_metadata: ~\n  - add_docker_metadata: ~\n  - add_kubernetes_metadata: ~\n\nlogging.level: debug\nlogging.to_files: true\nlogging.files:\n  path: /var/log/filebeat\n  name: filebeat\n  keepfiles: 7\nEOF\n'",
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

# Configure Filebeat to collect and forward Couchbase audit logs
resource "null_resource" "filebeat_config" {
  count = var.enable_filebeat ? 1 : 0

  triggers = {
    server_ip              = var.server_ip
    couchbase_cluster_name = var.couchbase_cluster_name
    gdp_mu_host            = var.gdp_mu_host
    logstash_port          = var.logstash_port
  }

  provisioner "local-exec" {
    command = <<-EOT
      sshpass -p '${var.server_password}' ssh -o StrictHostKeyChecking=no ${var.server_username}@${var.server_ip} bash -s <<'ENDSSH'
${join("\n", local.filebeat_commands)}
ENDSSH
    EOT
  }

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
  depends_on = [null_resource.filebeat_config]
}

#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

# On-Premises Couchbase Audit Configuration Module
# This module configures Filebeat to collect Couchbase audit logs and forward them to Guardium

locals {
  # Build SSL configuration conditionally
  ssl_config = var.ssl_enable ? "  ssl.enabled: true\n  ssl.verification_mode: ${var.ssl_verify ? "full" : "none"}\n  ssl.certificate_authorities: [\"${var.ssl_cert_path}\"]" : ""

  filebeat_config_commands = [
    # Backup existing filebeat.yml
    "sudo cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.backup.$(date +%Y%m%d_%H%M%S)",

    # Create Filebeat configuration
    <<-EOT
    sudo bash -c 'cat > /etc/filebeat/filebeat.yml << "EOFCONFIG"
###################### Filebeat Configuration for Couchbase ###################

filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - ${var.couchbase_audit_log_path}
    tags: ["couchbasedb"]

filebeat.config.modules:
  path: $${path.config}/modules.d/*.yml
  reload.enabled: false

setup.template.settings:
  index.number_of_shards: 1

setup.kibana:

output.logstash:
  hosts: ["${var.gdp_mu_host}:${var.logstash_port}"]
${local.ssl_config}

processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
  - add_cloud_metadata: ~
  - add_docker_metadata: ~
  - add_kubernetes_metadata: ~

logging.level: debug
logging.to_files: true
logging.files:
  path: /var/log/filebeat
  name: filebeat
  keepfiles: 7
EOFCONFIG
'
EOT
    ,

    # Set proper permissions
    "sudo chmod 644 /etc/filebeat/filebeat.yml",

    # Enable and restart Filebeat service
    "sudo systemctl enable filebeat",
    "sudo systemctl restart filebeat",

    # Wait for Filebeat to start
    "sleep 5",

    # Verify Filebeat is running
    "sudo systemctl status filebeat --no-pager"
  ]

  couchbase_audit_config_commands = [
    # Enable audit logging in Couchbase
    "curl -X POST http://${var.couchbase_host}:${var.couchbase_admin_port}/settings/audit \\",
    "  -u ${var.couchbase_admin_username}:${var.couchbase_admin_password} \\",
    "  -d auditdEnabled=true \\",
    "  -d rotateInterval=86400 \\",
    "  -d logPath=${var.couchbase_audit_log_path}",

    # Verify audit configuration
    "curl -X GET http://${var.couchbase_host}:${var.couchbase_admin_port}/settings/audit \\",
    "  -u ${var.couchbase_admin_username}:${var.couchbase_admin_password}"
  ]
}

# Configure Couchbase audit logging
resource "null_resource" "couchbase_audit_config" {
  count = var.enable_audit_log ? 1 : 0

  triggers = {
    server_ip              = var.server_ip
    couchbase_cluster_name = var.couchbase_cluster_name
    audit_log_path         = var.couchbase_audit_log_path
  }

  connection {
    type     = "ssh"
    host     = var.server_ip
    user     = var.server_username
    password = var.server_password
    timeout  = "10m"
  }

  provisioner "remote-exec" {
    inline     = local.couchbase_audit_config_commands
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

  connection {
    type     = "ssh"
    host     = var.server_ip
    user     = var.server_username
    password = var.server_password
    timeout  = "10m"
  }

  provisioner "remote-exec" {
    inline     = local.filebeat_config_commands
    on_failure = continue
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

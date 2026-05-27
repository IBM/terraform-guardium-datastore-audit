#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

# Apache Cassandra Audit Configuration Module
# This module configures Filebeat to forward Cassandra audit logs to Guardium

locals {
  # Commands to configure Filebeat on the Cassandra server
  filebeat_commands = [
    # Backup existing filebeat.yml if it exists
    "sudo test -f /etc/filebeat/filebeat.yml && sudo cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.backup || true",

    # Create Filebeat configuration for Cassandra audit logs
    "sudo bash -c 'cat > /etc/filebeat/filebeat.yml << EOF",
    "filebeat.inputs:",
    "- type: filestream",
    "  id: cassandra-audit-dse",
    "  enabled: true",
    "  paths:",
    "    - ${var.cassandra_audit_log_path}",
    "  exclude_lines: [\"AuditLogManager\"]",
    "  tags: [\"${var.datasource_tag}\"]",
    "",
    "  # Multi-line pattern for Cassandra audit logs",
    "  multiline.type: pattern",
    "  multiline.pattern: \"^INFO\"",
    "  multiline.negate: true",
    "  multiline.match: after",
    "",
    "# Output to Guardium Universal Connector",
    "output.logstash:",
    "  hosts: [\"${var.gdp_mu_host}:${var.logstash_port}\"]",
    "",
    "# Logging configuration",
    "logging.level: info",
    "logging.to_files: true",
    "logging.files:",
    "  path: /var/log/filebeat",
    "  name: filebeat",
    "  keepfiles: 7",
    "  permissions: 0644",
    "",
    "logging.level: debug",
    "logging.selectors: [\"*\"]",
    "EOF",
    "'",

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

resource "null_resource" "cassandra_filebeat_setup" {
  count = var.enable_filebeat_setup ? 1 : 0

  # Triggers to force recreation when critical variables change
  triggers = {
    server_ip                  = var.server_ip
    cassandra_audit_log_path   = var.cassandra_audit_log_path
    gdp_mu_host                = var.gdp_mu_host
    logstash_port              = var.logstash_port
  }

  # SSH connection to Cassandra server
  connection {
    type     = "ssh"
    host     = var.server_ip
    user     = var.server_username
    password = var.server_password
    timeout  = "10m"
  }

  provisioner "remote-exec" {
    inline     = local.filebeat_commands
    on_failure = continue
  }
}

locals {
  udc_name = var.udc_name != "" ? var.udc_name : format("onprem-cassandra-%s", var.cassandra_instance_identifier)
}

# Generate the CSV content from the template
locals {
  onprem_cassandra_csv = templatefile("${path.module}/templates/onprem-cassandra.tpl", {
    udc_name       = local.udc_name
    description    = var.csv_description != "" ? var.csv_description : "GDP On-Premises Cassandra connector for ${var.cassandra_instance_identifier}"
    datasource_tag = var.datasource_tag
    port           = var.logstash_port
  })
}

# Connect datasource to Guardium Universal Connector
module "gdp_connect-datasource-to-uc" {
  source         = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  count          = var.enable_universal_connector ? 1 : 0
  udc_name       = local.udc_name
  udc_csv_parsed = local.onprem_cassandra_csv

  # Guardium configuration
  client_id     = var.gdp_client_id
  client_secret = var.gdp_client_secret
  gdp_server    = var.gdp_server
  gdp_port      = var.gdp_port
  gdp_username  = var.gdp_username
  gdp_password  = var.gdp_password
  gdp_mu_host   = var.gdp_mu_host

  # Wait for Filebeat setup to complete before creating connector
  depends_on = [null_resource.cassandra_filebeat_setup]
}
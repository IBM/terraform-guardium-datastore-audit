#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

locals {
  windows_commands = [
    # Backup my.ini before modification
    "Copy-Item -Path '${var.mysql_config_path}' -Destination '${var.mysql_config_path}.backup' -Force",

    # Append audit plugin configuration to my.ini
    "Add-Content -Path '${var.mysql_config_path}' -Value ''",
    "Add-Content -Path '${var.mysql_config_path}' -Value 'plugin-load = audit_log.dll'",
    "Add-Content -Path '${var.mysql_config_path}' -Value 'audit_log_format=JSON'",

    # Restart MySQL service
    "Restart-Service -Name '${var.mysql_service_name}' -Force",

    # Wait for MySQL to be ready
    "Start-Sleep -Seconds 10",

    # Create log-all filter
    "& '${var.mysql_bin_path}\\mysql.exe' -u root -p${var.mysql_root_password} -e \"SELECT audit_log_filter_set_filter('log_all', '{ \\\"filter\\\": { \\\"log\\\": true } }');\"",

    # Assign filter to all users
    "& '${var.mysql_bin_path}\\mysql.exe' -u root -p${var.mysql_root_password} -e \"SELECT audit_log_filter_set_user('%', 'log_all');\""
  ]

  linux_commands = [
    # Install audit plugin
    "cd ${var.mysql_install_path}",
    "mysql -u root -p${var.mysql_root_password} mysql < ${var.mysql_install_path}/audit_log_filter_linux_install.sql",

    # Verify plugin installation
    "sudo mysql -u root -p${var.mysql_root_password} -e \"SELECT PLUGIN_NAME, PLUGIN_STATUS FROM INFORMATION_SCHEMA.PLUGINS WHERE PLUGIN_NAME LIKE 'audit%';\"",

    # Backup my.cnf before modification
    "sudo cp /etc/my.cnf /etc/my.cnf.backup",

    # Add plugin-load and audit_log_format to my.cnf if not present
    "sudo grep -q 'plugin-load=audit_log.so' /etc/my.cnf || sudo sed -i '/\\[mysqld\\]/a plugin-load=audit_log.so' /etc/my.cnf",
    "sudo grep -q 'audit_log_format=JSON' /etc/my.cnf || sudo sed -i '/\\[mysqld\\]/a audit_log_format=JSON' /etc/my.cnf",

    # Add port=5143 to my.cnf if not present
    "sudo grep -q 'port=5143' /etc/my.cnf || sudo sed -i '/\\[mysqld\\]/a port=5143' /etc/my.cnf",

    # Add audit-log=FORCE_PLUS_PERMANENT to prevent runtime removal
    "sudo grep -q 'audit-log=FORCE_PLUS_PERMANENT' /etc/my.cnf || sudo sed -i '/\\[mysqld\\]/a audit-log=FORCE_PLUS_PERMANENT' /etc/my.cnf",

    # Restart MySQL
    "sudo systemctl restart mysqld",

    # Wait for MySQL to be ready
    "sleep 10",

    # Create log-all filter
    "sudo mysql -u root -p${var.mysql_root_password} -e \"SELECT audit_log_filter_set_filter('log_all', '{ \\\"filter\\\": { \\\"log\\\": true } }');\"",

    # Assign filter to all users
    "sudo mysql -u root -p${var.mysql_root_password} -e \"SELECT audit_log_filter_set_user('%', 'log_all');\"",

    # Configure rsyslog to forward MySQL audit logs to Logstash
    # Append to /etc/rsyslog.conf instead of creating separate file in rsyslog.d
    "sudo bash -c 'cat >> /etc/rsyslog.conf << EOF\n\n# MySQL Audit Log Forwarding\n\\$ModLoad imfile\n\\$InputFileName /var/lib/mysql/audit.log\n\\$InputFileTag mysql_audit_log:\n\\$InputFileStateFile audit_log\n\\$InputFileSeverity info\n\\$InputFileFacility local6\n\\$InputRunFileMonitor\n\n# Forward to Logstash on Guardium server (UDP)\nlocal6.* @${var.gdp_mu_host}:${var.syslog_port}\nEOF\n'",

    # Restart rsyslog to apply configuration
    "sudo systemctl restart rsyslog",

    # Verify rsyslog is running
    "sudo systemctl status rsyslog --no-pager"
  ]
}

resource "null_resource" "mysql_audit" {
  count = var.enable_audit_log ? 1 : 0

  # Windows connection
  connection {
    type     = var.is_windows ? "winrm" : "ssh"
    host     = var.server_ip
    user     = var.server_username
    password = var.server_password

    # WinRM-specific
    https    = var.is_windows ? false : null
    insecure = var.is_windows ? true : null
  }

  provisioner "remote-exec" {
    inline = var.is_windows ? local.windows_commands : local.linux_commands
  }
}

locals {
  udc_name = var.udc_name != "" ? var.udc_name : format("mysql-syslog-%s", var.mysql_instance_identifier)
}

# Generate the CSV content from the template
locals {
  mysql_syslog_csv = templatefile("${path.module}/templates/mysql-syslog.tpl", {
    udc_name                           = local.udc_name
    syslog_port                        = var.syslog_port
    ssl_enable                         = var.ssl_enable
    ssl_verify                         = var.ssl_verify
    description                        = "GDP MySQL Syslog connector for ${var.mysql_instance_identifier}"
    ssl_certificate_authority_filename = var.ssl_certificate_authority_filename
  })
}

# resource "local_file" "mysql_syslog_csv" {
#   content  = local.mysql_syslog_csv
#   filename = "${path.module}/output/mysql_syslog.csv"
# }

module "gdp_connect-datasource-to-uc" {
  source         = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  count          = var.enable_universal_connector ? 1 : 0
  udc_name       = local.udc_name
  udc_csv_parsed = local.mysql_syslog_csv

  # Guardium configuration
  client_id     = var.gdp_client_id
  client_secret = var.gdp_client_secret
  gdp_server    = var.gdp_server
  gdp_port      = var.gdp_port
  gdp_username  = var.gdp_username
  gdp_password  = var.gdp_password
  gdp_mu_host   = var.gdp_mu_host
}

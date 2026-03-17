#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#
# locals {
#   mysql_audit_script = <<-EOF
#     $ErrorActionPreference = 'Stop'

#     Write-Host "Starting MySQL audit configuration..."

#     # Backup my.ini
#     $config = "${var.mysql_config_path}"
#     $backup = "$config.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
#     Copy-Item $config $backup -Force
#     Write-Host "Backup created: $backup"

#     # Ensure plugin-load
#     if (-not (Select-String -Path $config -Pattern 'plugin-load = audit_log.dll' -Quiet)) {
#       Add-Content -Path $config -Value 'plugin-load = audit_log.dll'
#       Write-Host "Added plugin-load"
#     }

#     # Ensure audit_log_format
#     if (-not (Select-String -Path $config -Pattern 'audit_log_format = JSON' -Quiet)) {
#       Add-Content -Path $config -Value 'audit_log_format = JSON'
#       Write-Host "Added audit_log_format"
#     }

#     # Restart MySQL
#     Restart-Service -Name "${var.mysql_service_name}" -Force
#     Start-Sleep -Seconds 3

#     # Wait for MySQL
#     for ($i = 1; $i -le 30; $i++) {
#       & "${var.mysql_bin_path}\\mysql.exe" -u root "-p${var.mysql_root_password}" -e "SELECT 1;" 2>$null
#       if ($LASTEXITCODE -eq 0) { break }
#       Start-Sleep -Seconds 2
#     }

#     # Create audit filter
#     & "${var.mysql_bin_path}\\mysql.exe" -u root "-p${var.mysql_root_password}" -e "SELECT audit_log_filter_set_filter('log_all', '{ \"filter\": { \"log\": true } }');"

#     # Assign filter to all users
#     & "${var.mysql_bin_path}\\mysql.exe" -u root "-p${var.mysql_root_password}" -e "SELECT audit_log_filter_set_user('%', 'log_all');"

#     Write-Host "MySQL audit configuration completed successfully!"
#   EOF
# }

# # Create local PowerShell script file
# resource "local_file" "mysql_audit_script" {
#   count    = var.enable_audit_log && var.is_windows ? 1 : 0
#   content  = local.mysql_audit_script
#   filename = "${path.module}/output/mysql_audit.ps1"
# }

locals {
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

# STEP 4: Full working resource with SSH connection (faster and more stable than WinRM)
# resource "null_resource" "mysql_audit_windows" {
#   count = var.enable_audit_log && var.is_windows && var.auto_enable_mysql_audit_in_window ? 1 : 0

#   # # Depend on local file creation
#   # depends_on = [local_file.mysql_audit_script]

#   # Triggers to force recreation when critical variables change
#   triggers = {
#     server_ip           = var.server_ip
#     mysql_root_password = md5(var.mysql_root_password)
#     mysql_config_path   = var.mysql_config_path
#     mysql_service_name  = var.mysql_service_name
#     # script_hash         = md5(local.mysql_audit_script)
#     script_shell = "powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command"
#   }

#   # SSH connection for Windows (requires OpenSSH Server enabled)
#   connection {
#     type            = "ssh"
#     host            = var.server_ip
#     user            = var.server_username
#     password        = var.server_password
#     port            = 22
#     timeout         = "10m"
#     target_platform = "windows"
#   }

#   # STEP 2 & 3: Write script content and execute (avoids file provisioner)
#   provisioner "remote-exec" {
#     inline = [
#       ## This is a test scritp to verify ssh Connection
#       # "powershell.exe -NoProfile -Command \"Write-Host 'SSH connection successful!'\""


#       # 1. Append the audit log configuration to my.ini
#       "powershell.exe -NoProfile -Command \"Add-Content -Path '${var.mysql_config_path}' -Value 'plugin-load=audit_log.dll' -Encoding ASCII\"",
#       "powershell.exe -NoProfile -Command \"Add-Content -Path '${var.mysql_config_path}' -Value 'audit_log_format=JSON' -Encoding ASCII\"",

#       # 2. Restart the MySQL service to load the plugin
#       "powershell.exe -NoProfile -Command \"Restart-Service -Name '${var.mysql_service_name}' -Force\""

#     ]
#   }
# }
resource "null_resource" "mysql_audit_windows" {
  count = var.enable_audit_log && var.is_windows && var.auto_enable_mysql_audit_in_window ? 1 : 0

  triggers = {
    server_ip           = var.server_ip
    mysql_root_password = md5(var.mysql_root_password)
    mysql_config_path   = var.mysql_config_path
    mysql_service_name  = var.mysql_service_name
    gdp_mu_host         = var.gdp_mu_host
  }

  connection {
    type            = "ssh"
    host            = var.server_ip
    user            = var.server_username
    password        = var.server_password
    port            = 22
    timeout         = "10m"
    target_platform = "windows"
  }

  # # Upload NXLog installer
  # provisioner "file" {
  #   source      = var.nxlog_installer_path
  #   destination = "C:\\Users\\Administrator\\Downloads\\nxlog-ce-3.2.2329.msi"
  # }

  # Upload NXLog config template
  provisioner "file" {
    content = templatefile("${path.module}/templates/nxlog.conf.tpl", {

      mysql_audit_log_file_pattern = var.mysql_audit_log_file_pattern
      guardium_ip                  = var.gdp_mu_host
      syslog_port                  = var.syslog_port
    })
    destination = "C:/nxlog.conf.tmp"
  }

  provisioner "remote-exec" {
    inline = [

      # Move temp config to the final destination locally on the server
      "move /Y C:\\nxlog.conf.tmp \"C:\\Program Files\\nxlog\\conf\\nxlog.conf\"",


      # --- MySQL AUDIT LOG CONFIGURATION ---
      "powershell.exe -NoProfile -Command \"Add-Content -Path '${var.mysql_config_path}' -Value 'plugin-load=audit_log.dll' -Encoding ASCII\"",
      "powershell.exe -NoProfile -Command \"Add-Content -Path '${var.mysql_config_path}' -Value 'audit_log_format=JSON' -Encoding ASCII\"",
      "powershell.exe -NoProfile -Command \"Add-Content -Path '${var.mysql_config_path}' -Value 'audit_log_policy=ALL' -Encoding ASCII\"",
      "powershell.exe -NoProfile -Command \"Add-Content -Path '${var.mysql_config_path}' -Value 'audit_log_file=C:/mysql_audit.log' -Encoding ASCII\"",

      # Restart MySQL to apply audit settings
      "powershell.exe -NoProfile -Command \"Restart-Service -Name '${var.mysql_service_name}' -Force\"",

      # --- NXLOG INSTALLATION ---
      "msiexec /i C:\\Windows\\Temp\\nxlog.msi /qn",

      # Restart NXLog to load new config
      "powershell.exe -NoProfile -Command \"Restart-Service nxlog -Force\""
    ]
  }
}

resource "null_resource" "mysql_audit_linux" {
  count = var.enable_audit_log && !var.is_windows ? 1 : 0

  # Triggers to force recreation when critical variables change
  triggers = {
    server_ip           = var.server_ip
    mysql_root_password = md5(var.mysql_root_password)
    mysql_install_path  = var.mysql_install_path
  }

  # Use traditional remote-exec for Linux
  connection {
    type     = "ssh"
    host     = var.server_ip
    user     = var.server_username
    password = var.server_password
    timeout  = "5m"
  }

  provisioner "remote-exec" {
    inline = local.linux_commands
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

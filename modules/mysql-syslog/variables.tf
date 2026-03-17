#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# MySQL Instance variables

variable "mysql_instance_identifier" {
  type        = string
  description = "Unique identifier for the MySQL instance"
}

variable "mysql_host" {
  type        = string
  description = "Hostname or IP address of the MySQL server"
}

variable "syslog_port" {
  type        = string
  description = "Port number of the MySQL server"
  default     = "5143"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
  default     = {}
}

# Guardium variables

variable "udc_name" {
  type        = string
  description = "Name for universal connector. If not provided, will be auto-generated"
  default     = ""
}

variable "gdp_client_secret" {
  type        = string
  description = "Client secret from output of grdapi register_oauth_client"
  sensitive   = true
}

variable "gdp_client_id" {
  type        = string
  description = "Client id used when running grdapi register_oauth_client"
}

variable "gdp_server" {
  type        = string
  description = "Hostname/IP address of Guardium Central Manager"
}

variable "gdp_port" {
  type        = string
  description = "Port of Guardium Central Manager"
  default     = "8443"
}

variable "gdp_username" {
  type        = string
  description = "Username of Guardium Web UI user"
}

variable "gdp_password" {
  type        = string
  description = "Password of Guardium Web UI user"
  sensitive   = true
}

variable "gdp_mu_host" {
  type        = string
  description = "Comma separated list of Guardium Managed Units to deploy profile"
  default     = ""
}

# Universal Connector Control

variable "enable_universal_connector" {
  type        = bool
  description = "Whether to enable the universal connector module. Set to false to completely disable the universal connector for a run."
  default     = true
}

# Syslog Configuration

variable "ssl_enable" {
  type        = bool
  description = "Enable SSL/TLS for syslog connection"
  default     = true
}

variable "ssl_certificate_authority_filename" {
  type        = string
  description = "Filename of the SSL certificate authority"
  default     = ""
}

variable "ssl_cert_path" {
  type        = string
  description = "Path to SSL certificate file (tls-syslog.crt)"
  default     = "/service/certs/external/tls-syslog.crt"
}

variable "ssl_key_path" {
  type        = string
  description = "Path to SSL private key file (tls-syslog.key)"
  default     = "/service/certs/external/tls-syslog.key"
}

variable "ssl_verify" {
  type        = bool
  description = "Enable SSL certificate verification"
  default     = true
}

variable "dns_reverse_lookup_enabled" {
  type        = bool
  description = "Enable DNS reverse lookup for incoming connections"
  default     = false
}
variable "enable_audit_log" {
  type        = bool
  description = "Enable MySQL audit logging configuration. Set to false to skip audit setup."
  default     = true
}

variable "is_windows" {
  type        = bool
  description = "If true, run Windows audit setup; otherwise run Linux setup. Required when enable_audit_log = true."
  default     = null
}

variable "server_ip" {
  type        = string
  description = "IP address or hostname of the MySQL server. Required when enable_audit_log = true."
  default     = ""
}

variable "server_username" {
  type        = string
  description = "Username for SSH/WinRM connection to the MySQL server. Required when enable_audit_log = true."
  default     = ""
}

variable "server_password" {
  type        = string
  description = "Password for SSH/WinRM connection to the MySQL server. Required when enable_audit_log = true."
  sensitive   = true
  default     = ""
}

variable "mysql_root_password" {
  type        = string
  description = "MySQL root password for database operations. Required when enable_audit_log = true."
  sensitive   = true
  default     = ""
}

variable "mysql_install_path" {
  type        = string
  description = "audit log filter linux install script path"
  default     = "/usr/share/mysql-9.6"
}

# Windows-specific variables

variable "auto_enable_mysql_audit_in_window" {
  type        = bool
  description = "Enable MySQL audit logging configuration. Set to false to skip audit setup."
  default     = false
}

variable "mysql_audit_log_file_pattern" {
  type        = string
  description = "Parent path of MySQL audit log path"
  default     = "C:\\MySQL\\server\\mysql-commercial-9.6.0-winx64\\data\\audit.*.log"
  # default = "C:\\MySQL\\server\\mysql-commercial-9.6.0-winx64\\data\\audit.20260317T033000.log"
}

variable "mysql_config_path" {
  type        = string
  description = "Path to MySQL configuration file (my.ini for Windows, my.cnf for Linux)"
  default     = "C:\\MySQL\\server\\mysql-commercial-9.6.0-winx64\\my.ini"
}

variable "mysql_service_name" {
  type        = string
  description = "Name of the MySQL Windows service"
  default     = "MySQL80"
}

variable "mysql_bin_path" {
  type        = string
  description = "Path to MySQL bin directory on Windows"
  default     = "C:\\MySQL\\server\\mysql-commercial-9.6.0-winx64\\bin"
}

variable "nxlog_installer_path" {
  description = "Path to the NXLog MSI installer"
  type        = string
  default     = "C:\\Users\\Administrator\\Downloads\\nxlog-ce-3.2.2329.msi"
}

variable "nxlog_config_template" {
  description = "Path to NXLog config template"
  type        = string
  default     = ""
}

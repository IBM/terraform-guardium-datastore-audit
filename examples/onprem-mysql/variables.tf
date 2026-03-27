#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

# MySQL Instance variables

variable "mysql_host" {
  type        = string
  description = "Hostname or IP address of the MySQL server"
}

variable "mysql_port" {
  type        = string
  description = "Port number of the MySQL server"
  default     = "3306"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
  default     = {}
}

variable "mysql_instance_identifier" {
  type        = string
  description = "Unique identifier for the MySQL instance"
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

variable "syslog_port" {
  type        = string
  description = "Port number for Logstash to listen for syslog messages"
  default     = "5143"
}

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

# Audit Configuration

variable "enable_audit_log" {
  type        = bool
  description = "Enable MySQL audit logging configuration. Set to false to skip audit setup."
  default     = true
}

# Server Connection variables (Linux)

variable "server_ip" {
  type        = string
  description = "IP address or hostname of the MySQL server for SSH connection"
}

variable "server_username" {
  type        = string
  description = "Username for SSH connection to the MySQL server"
}

variable "server_password" {
  type        = string
  description = "Password for SSH connection to the MySQL server"
  sensitive   = true
}

variable "mysql_root_password" {
  type        = string
  description = "MySQL root password for database operations"
  sensitive   = true
}

variable "mysql_install_path" {
  type        = string
  description = "Path to MySQL audit log filter install script"
  default     = "/usr/share/mysql-9.6"
}


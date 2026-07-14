#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

# Couchbase Instance variables

variable "couchbase_cluster_name" {
  type        = string
  description = "Unique identifier for the Couchbase cluster"
}

variable "couchbase_host" {
  type        = string
  description = "Hostname or IP address of the Couchbase server"
}

variable "couchbase_admin_port" {
  type        = string
  description = "Couchbase admin port"
  default     = "8091"
}

variable "couchbase_admin_username" {
  type        = string
  description = "Couchbase administrator username"
  sensitive   = true
}

variable "couchbase_admin_password" {
  type        = string
  description = "Couchbase administrator password"
  sensitive   = true
}

variable "couchbase_audit_log_path" {
  type        = string
  description = "Path to Couchbase audit log file pattern (supports wildcards)"
  default     = "/opt/couchbase/var/lib/couchbase/logs/*-audit.log"
}

variable "logstash_port" {
  type        = string
  description = "Port number for Logstash on Guardium server"
  default     = "5044"
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

# Filebeat Configuration

variable "enable_filebeat" {
  type        = bool
  description = "Enable Filebeat configuration. Set to false to skip Filebeat setup."
  default     = true
}

variable "ssl_enable" {
  type        = bool
  description = "Enable SSL/TLS for Logstash connection"
  default     = true
}

variable "ssl_certificate_authority_filename" {
  type        = string
  description = "Filename of the SSL certificate authority"
  default     = ""
}

variable "ssl_cert_path" {
  type        = string
  description = "Path to SSL certificate file on the Couchbase server"
  default     = "/etc/pki/tls/certs/logstash-forwarder.crt"
}

variable "ssl_verify" {
  type        = bool
  description = "Enable SSL certificate verification"
  default     = true
}

# Audit Configuration

variable "enable_audit_log" {
  type        = bool
  description = "Enable Couchbase audit logging configuration. Set to false to skip audit setup."
  default     = true
}

variable "server_ip" {
  type        = string
  description = "IP address or hostname of the Couchbase server. Required when enable_audit_log = true or enable_filebeat = true."
  default     = ""
}

variable "server_username" {
  type        = string
  description = "Username for SSH connection to the Couchbase server. Required when enable_audit_log = true or enable_filebeat = true."
  default     = ""
}

variable "server_password" {
  type        = string
  description = "Password for SSH connection to the Couchbase server. Required when enable_audit_log = true or enable_filebeat = true."
  sensitive   = true
  default     = ""
}

variable "ssh_port" {
  type        = number
  description = "SSH port for connecting to the Couchbase server"
  default     = 22
}

# CSV Configuration

variable "csv_description" {
  type        = string
  description = "Description for the UDC connector"
  default     = ""
}

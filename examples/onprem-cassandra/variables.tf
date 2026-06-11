#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

# Cassandra Instance Variables

variable "cassandra_instance_identifier" {
  type        = string
  description = "Unique identifier for the Cassandra instance"
}

variable "cassandra_host" {
  type        = string
  description = "Hostname or IP address of the Cassandra server"
}

variable "cassandra_audit_log_path" {
  type        = string
  description = "Path to Cassandra audit log file"
  default     = "/var/log/cassandra/audit/audit.log"
}

variable "logstash_port" {
  type        = string
  description = "Port number for Logstash on Guardium server (used in Filebeat output and UDC template)"
}

variable "datasource_tag" {
  type        = string
  description = "Datasource tag for identifying the Cassandra instance in Guardium (required)"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
  default     = {}
}

# Guardium Variables

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
  description = "Whether to enable the universal connector module"
  default     = true
}

# Filebeat Configuration

variable "enable_filebeat_setup" {
  type        = bool
  description = "Enable Filebeat configuration on Cassandra server"
  default     = true
}

variable "server_ip" {
  type        = string
  description = "IP address or hostname of the Cassandra server for SSH connection"
}

variable "server_username" {
  type        = string
  description = "Username for SSH connection to the Cassandra server"
}

variable "server_password" {
  type        = string
  description = "Password for SSH connection to the Cassandra server"
  sensitive   = true
}

# CSV/UDC Configuration

variable "csv_description" {
  type        = string
  description = "Description for the UDC connector"
  default     = ""
}
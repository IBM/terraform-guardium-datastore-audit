#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

//////
// AWS variables
//////

variable "aws_region" {
  type        = string
  description = "This is the AWS region."
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
}

variable "neptune_cluster_identifier" {
  type        = string
  description = "Neptune cluster identifier to be monitored"
}

//////
// General variables
//////
variable "udc_aws_credential" {
  type        = string
  description = "name of AWS credential defined in Guardium"
}

variable "gdp_client_secret" {
  type        = string
  description = "Client secret from output of grdapi register_oauth_client"
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
}

//////
// Universal Connector Control
//////

variable "enable_universal_connector" {
  type        = bool
  description = "Whether to enable the universal connector module. Set to false to completely disable the universal connector for a run."
  default     = true
}

variable "csv_start_position" {
  type        = string
  description = "Start position for UDC"
  default     = "end"
}

variable "csv_interval" {
  type        = string
  description = "Polling interval for UDC"
  default     = "5"
}

variable "csv_event_filter" {
  type        = string
  description = "UDC Event filters"
  default     = ""
}

variable "codec_pattern" {
  type        = string
  description = "Codec pattern for the Universal Connector"
  default     = ""
}

variable "neptune_endpoint" {
  type        = string
  description = "Neptune cluster endpoint (optional - will be fetched automatically if not provided)"
  default     = ""
}

variable "use_aws_bundled_ca" {
  type        = bool
  description = "Whether to use AWS bundled CA certificates for Neptune connections"
  default     = true
}

//////
// SFTP and Multipart Upload Configuration
//////




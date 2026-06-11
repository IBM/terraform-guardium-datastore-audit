#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

//////
// GCP variables
//////

variable "gcp_project_id" {
  type        = string
  description = "GCP project ID where the AlloyDB cluster is located. IMPORTANT: You MUST set this value in your terraform.tfvars file."
}

variable "gcp_region" {
  type        = string
  description = "GCP region where the AlloyDB cluster is located"
  default     = "us-central1"
}

variable "alloydb_cluster_id" {
  type        = string
  description = "AlloyDB cluster identifier to be monitored"
}

variable "pubsub_topic_id" {
  type        = string
  description = "Pub/Sub topic ID for AlloyDB audit logs"
  default     = "guardium-alloydb-audit-logs"
}

variable "pubsub_subscription_id" {
  type        = string
  description = "Pub/Sub subscription ID for AlloyDB audit logs"
  default     = "guardium-alloydb-audit-logs-sub"
}

variable "enable_audit_logging" {
  type        = bool
  description = "Whether to create the AlloyDB Pub/Sub topic, subscription, and Cloud Logging sink"
  default     = true
}

variable "audit_log_sink_name" {
  type        = string
  description = "Optional Cloud Logging sink name. If empty, defaults to <alloydb_cluster_id>-audit-sink"
  default     = ""
}

variable "pubsub_ack_deadline" {
  type        = number
  description = "Acknowledgement deadline in seconds for the AlloyDB audit Pub/Sub subscription"
  default     = 60
}

//////
// General variables
//////

variable "udc_name" {
  type        = string
  description = "Name for universal connector. Is used for all GCP objects"
  default     = "alloydb-audit-connector"
}

variable "udc_gcp_credential" {
  type        = string
  description = "Name of GCP credential defined in Guardium"
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
  default     = ""
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
  description = "Start position for UDC (beginning, end)"
  default     = "end"
}

//////
// Pub/Sub Configuration
//////

variable "max_messages" {
  type        = number
  description = "Maximum number of messages to pull from Pub/Sub in a single request"
  default     = 100
}
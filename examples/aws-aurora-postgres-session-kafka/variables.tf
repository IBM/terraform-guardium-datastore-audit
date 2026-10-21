#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

//////
// AWS variables
//////

variable "aws_region" {
  type        = string
  description = "This is the AWS region. IMPORTANT: You MUST set this value in your terraform.tfvars file."
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
  default     = {}
}

variable "aurora_postgres_cluster_identifier" {
  type        = string
  description = "Aurora PostgreSQL cluster identifier to be monitored"
}

variable "force_failover" {
  type        = bool
  default     = true
  description = "To failover the database instance, requires multi AZ databases. Results in minimal downtime"
}

variable "skip_reboot" {
  description = "Skip automatic reboot (audit logging won't work until manual reboot)"
  type        = bool
  default     = true
}

variable "pg_audit_log" {
  type        = string
  description = "PGAudit log configuration for session auditing"
  default     = "all, -misc"
}

//////
// General variables
//////
variable "udc_name" {
  type        = string
  description = "Override name for the universal connector profile. Defaults to {aws_region}-{aurora_postgres_cluster_identifier}-{aws_account_id}"
  default     = ""
}

variable "udc_aws_credential" {
  type        = string
  description = "name of AWS credential defined in Guardium"
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

//////
// Universal Connector Control
//////

variable "enable_audit_setup" {
  type        = bool
  description = "Whether to configure pgAudit on the cluster (parameter group). Set to false to skip audit logging setup and only manage the Universal Connector."
  default     = true
}

variable "enable_universal_connector" {
  type        = bool
  description = "Whether to enable the universal connector module. Set to false to completely disable the universal connector for a run."
  default     = true
}

//////
// Kafka-specific UC variables
//////

variable "kafka_cluster_name" {
  type        = string
  description = "Kafka cluster name for Kafka-based UC"
  default     = "kafka"
}

variable "use_elb" {
  type        = bool
  description = "Whether to use ELB for Kafka-based UC"
  default     = false
}

variable "event_delay" {
  type        = number
  description = "Event delay in minutes for Kafka-based UC"
  default     = 15
}

variable "nodata_threshold_min" {
  type        = number
  description = "No data threshold in minutes for Kafka-based UC"
  default     = 60
}

variable "unmask" {
  type        = bool
  description = "Whether to unmask sensitive data in audit logs"
  default     = false
}

variable "filter_pattern" {
  type        = string
  description = "CloudWatch Logs filter pattern for filtering audit logs"
  default     = "None"
}

variable "poll_interval_sec" {
  type        = number
  description = "Poll interval seconds component (0-59) for Kafka-based UC. Added to poll_interval (minutes)"
  default     = 30

  validation {
    condition     = var.poll_interval_sec >= 0 && var.poll_interval_sec <= 59 && var.poll_interval_sec == floor(var.poll_interval_sec)
    error_message = "poll_interval_sec must be a whole number between 0 and 59."
  }
}

variable "poll_interval" {
  type        = number
  description = "Poll interval in minutes for Kafka-based UC"
  default     = 0
}

variable "event_limit" {
  type        = number
  description = "Maximum number of events to retrieve per poll for Kafka-based UC"
  default     = 1000
}

variable "timestamp_start" {
  type        = string
  description = "Initial polling time for Kafka-based UC, in UTC ISO 8601 with milliseconds, e.g. 2026-10-19T21:17:05.000Z. Leave empty to use the current time (UTC), recorded at first apply"
  default     = ""

  validation {
    condition     = can(regex("^([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\\.[0-9]{3}Z)?$", var.timestamp_start))
    error_message = "timestamp_start must be empty or UTC ISO 8601 with milliseconds, e.g. 2026-10-19T21:17:05.000Z."
  }
}

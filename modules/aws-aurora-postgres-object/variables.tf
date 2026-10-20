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
  default     = {}
}

variable "aurora_postgres_cluster_identifier" {
  type        = string
  default     = "guardium-aurora-postgres"
  description = "Aurora PostgreSQL cluster identifier to be monitored"
}

variable "force_failover" {
  type        = bool
  default     = false
  description = "To failover the database instance, requires multi AZ databases. Results in minimal downtime"
}

variable "skip_reboot" {
  description = "Skip automatic reboot (audit logging won't work until manual reboot)"
  type        = bool
  default     = true
}

variable "db_host" {
  type        = string
  description = "The hostname of the Aurora PostgreSQL cluster endpoint"
}

variable "db_port" {
  type        = number
  description = "The port of the Aurora PostgreSQL cluster"
  default     = 5432
}

variable "db_username" {
  type        = string
  description = "The master username for the Aurora PostgreSQL cluster"
}

variable "db_password" {
  type        = string
  description = "The master password for the Aurora PostgreSQL cluster"
  sensitive   = true
}

variable "db_name" {
  type        = string
  description = "The database to connect to"
  default     = "postgres"
}


variable "ssl_mode" {
  type        = string
  description = "SSL mode for PostgreSQL connection. Supported values: require, verify-full, verify-ca, disable"
  default     = "require"
}

//////
// General variables
//////
variable "udc_name" {
  type        = string
  description = "Name for universal connector. Is used for all aws objects"
  default     = "aurora-postgres-object"
}

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
  default     = ""
}

//////
// Universal Connector Control
//////

variable "enable_audit_setup" {
  type        = bool
  description = "Whether to configure pgAudit on the cluster (parameter group, role, and table grants). Set to false to skip audit logging setup and only manage the Universal Connector."
  default     = true
}

variable "enable_universal_connector" {
  type        = bool
  description = "Whether to enable the universal connector module. Set to false to completely disable the universal connector for a run."
  default     = true
}

variable "uc_mode" {
  type        = string
  description = "Universal Connector mode: 'cloudwatch', 'sqs', or 'kafka'"
  default     = "cloudwatch"

  validation {
    condition     = contains(["cloudwatch", "sqs", "kafka"], var.uc_mode)
    error_message = "uc_mode must be one of: 'cloudwatch', 'sqs', 'kafka'."
  }
}

variable "udc_description" {
  type        = string
  description = "Description for the Universal Connector profile"
  default     = ""
}

variable "csv_start_position" {
  type        = string
  description = "Start position for UDC (used when uc_mode is 'cloudwatch' or 'sqs')"
  default     = "end"
}

variable "csv_interval" {
  type        = string
  description = "Polling interval for UDC (used when uc_mode is 'cloudwatch' or 'sqs')"
  default     = "5"
}

variable "csv_event_filter" {
  type        = string
  description = "UDC Event filters (used when uc_mode is 'cloudwatch' or 'sqs')"
  default     = ""
}

variable "log_export_type" {
  description = "The type of log exporting to be configured. Options SQS, Cloudwatch. Ignored when uc_mode is 'kafka'."
  default     = "Cloudwatch"

  validation {
    condition     = var.log_export_type == "SQS" || var.log_export_type == "Cloudwatch"
    error_message = "log_export_type must be 'SQS' or 'Cloudwatch'"
  }
}

//////
// Kafka-specific UC variables
//////

variable "kafka_cluster_name" {
  type        = string
  description = "Kafka cluster name configured in Guardium (used when uc_mode is 'kafka')"
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

variable "poll_interval" {
  type        = number
  description = "Poll interval in minutes for Kafka-based UC"
  default     = 1
}

variable "event_limit" {
  type        = number
  description = "Maximum number of events to retrieve per poll for Kafka-based UC"
  default     = 1000
}

variable "start_time" {
  type        = number
  description = "Start time as epoch in milliseconds for Kafka-based UC (0 = disabled)"
  default     = 0
}


variable "tables" {
  description = "List of tables to monitor with object-level auditing"
  type = list(object({
    schema = string
    table  = string
    grants = list(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for table in var.tables : alltrue([
        for grant in table.grants : contains(["SELECT", "INSERT", "UPDATE", "DELETE", "REFERENCES", "TRIGGER", "ALL"], grant)
      ])
    ])
    error_message = "Valid grant options are: SELECT, INSERT, UPDATE, DELETE, REFERENCES, TRIGGER, ALL"
  }
}



variable "codec_pattern" {
  type        = string
  description = "Codec pattern for Aurora PostgreSQL CloudWatch logs"
  default     = "(((?<ts>[^[A-Z]{3}]*)UTC:(?<client_ip>[^:]*):(?<db_user>[^@]*)@(?<db_name>[^:]*):(?<session_id>[^:*]*):(?<logger>LOCATION|DETAIL|STATEMENT|HINT):%%{GREEDYDATA:sql_full_log})|(^\\s))"
}

variable "cloudwatch_endpoint" {
  type        = string
  description = "Custom endpoint URL for AWS CloudWatch. Leave empty to use default AWS endpoint"
  default     = ""
}

variable "use_aws_bundled_ca" {
  type        = bool
  description = "Whether to use the AWS bundled CA certificates for CloudWatch connection"
  default     = true
}


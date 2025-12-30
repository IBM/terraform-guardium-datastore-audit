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

variable "postgres_rds_cluster_identifier" {
  type        = string
  default = "guardium-postgres"
  description = "DocumentDB cluster identifier to be monitored"
}

variable "force_failover" {
  type        = bool
  default = true
  description = "To failover the database instance, requires multi AZ databases. Results in minimal downtime"
}

variable "db_host" {
  description = "The hostname of the RDS PostgreSQL instance"
  type        = string
}

variable "db_port" {
  description = "The port of the RDS PostgreSQL instance"
  type        = number
  default     = 5432
}

variable "db_username" {
  description = "The master username for the RDS PostgreSQL instance"
  type        = string
}

variable "db_password" {
  description = "The master password for the RDS PostgreSQL instance"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "The database to connect to"
  type        = string
  default     = "postgres"
}


variable "ssl_mode" {
  description = "SSL mode for postgres"
  type        = string
  default     = "prefer"
}

//////
// General variables
//////
variable "udc_name" {
  type        = string
  description = "Name for universal connector. Is used for all aws objects"
  default     = "documentdb-gdp"
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

variable "log_export_type" {
  description = "The type of log exporting to be configured. Options SQS, Cloudwatch"
  default = "object"

  validation {
    condition = var.log_export_type == "SQS" || var.log_export_type == "Cloudwatch"
    error_message = "log_export_type must be 'SQS' or 'Cloudwatch'"
  }
}

variable "tables" {
  type = list(object({
    schema = string
    table  = string
    grants = list(string)
  }))

  validation {
    condition = alltrue([
      for t in var.tables : alltrue([
        for g in t.grants : contains(
          ["SELECT", "INSERT", "UPDATE", "DELETE", "REFERENCES", "TRIGGER", "ALL"],
          upper(g)
        )
      ])
    ])

    error_message = "Each grant must be one of: SELECT, INSERT, UPDATE, DELETE,  REFERENCES, TRIGGER (case-insensitive)."
  }
  default = []
}



variable "codec_pattern" {
  type = string
  description = "Codec pattern for RDS PostgreSQL CloudWatch logs"
  default = "plain"
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


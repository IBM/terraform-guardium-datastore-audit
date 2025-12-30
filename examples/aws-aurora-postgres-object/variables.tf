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
  default = true
  description = "To failover the database instance, requires multi AZ databases. Results in minimal downtime"
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
  default     = "aurora-postgres-gdp-object"
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
  default = "Cloudwatch"

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

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

variable "documentdb_cluster_identifier" {
  type        = string
  description = "DocumentDB cluster identifier to be monitored"
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
}

variable "csv_interval" {
  type        = string
  description = "Polling interval for UDC"
  default     = "30"
}

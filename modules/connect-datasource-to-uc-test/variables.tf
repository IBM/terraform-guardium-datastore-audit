//////
// AWS variables
//////
variable "udc_csv_parsed" {
  type = string
  description = "The parsed csv profile"
}

//////
// Guardium variables
//////

variable "client_secret" {
  type        = string
  description = "The client secret output from grdapi register_oauth_client client_id=client1 grant_types=password"
}

variable "client_id" {
  type        = string
  description = "The client id used to create the gdp register_oauth_client client_secret"
}

variable "gdp_server" {
  type        = string
  description = "The hostname or IP address of the Guardium server"
}

variable "gdp_port" {
  type        = string
  description = "The hostname or IP address of the Guardium server"
  default     = "8443"
}

variable "gdp_username" {
  type        = string
  description = "The username to login to Guardium"
}

variable "gdp_password" {
  type        = string
  description = "The password for logging in to Guardium"
  sensitive   = true
}

variable "gdp_ssh_username" {
  type        = string
  description = "The ssh user for logging in to Guardium"
}

variable "gdp_ssh_privatekeypath" {
  type        = string
  description = "The path to the ssh privatekey for logging in to Guardium"
}

variable "gdp_mu_host" {
  type        = string
  description = "Comma separated list of Guardium Managed Units to deploy profile"
  default     = ""
}

variable "udc_name" {
  type        = string
  default     = ""
  description = "Universal Data Collector name. This will be the unique name used in the UI"
}

variable "log_directory" {
  type        = string
  description = "Directory on Guardium server where CSV configuration files will be stored"
  default     = "/var/IBM/Guardium/file-server/upload"
}
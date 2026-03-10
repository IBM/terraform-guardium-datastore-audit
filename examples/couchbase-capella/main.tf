# Couchbase Capella Audit Configuration Example
# This example enables audit logging on an existing Capella cluster

#----------------------------------------
# No Provider Configuration Here
# Providers are configured in versions.tf
#----------------------------------------

#----------------------------------------
# Capella Audit Configuration
#----------------------------------------
module "capella_audit" {
  source = "../../modules/couchbase-capella"

  # Existing Capella Cluster Configuration
  capella_organization_id = var.capella_organization_id
  capella_project_id      = var.capella_project_id
  capella_cluster_id      = var.capella_cluster_id
  capella_api_token       = var.capella_api_token
  auditlogsettings        = var.auditlogsettings

  # CSV/UDC Configuration
  csv_description    = var.csv_description
  csv_query_interval = var.csv_query_interval
  csv_query_length   = var.csv_query_length



  # Guardium Data Protection Configuration
  gdp_server        = var.gdp_server
  gdp_port          = var.gdp_port
  gdp_username      = var.gdp_username
  gdp_password      = var.gdp_password
  gdp_client_id     = var.gdp_client_id
  gdp_client_secret = var.gdp_client_secret
  gdp_mu_host       = var.gdp_mu_host

  # Universal Connector Configuration
  enable_universal_connector = var.enable_universal_connector
}

# Outputs from the module
output "udc_name" {
  value       = module.capella_audit.udc_name
  description = "Name of the Universal Connector"
}

output "audit_enabled" {
  value       = module.capella_audit.audit_enabled
  description = "Whether audit logging is enabled"
}

output "enabled_event_ids" {
  value       = module.capella_audit.enabled_event_ids
  description = "List of enabled audit event IDs"
}

output "capella_cluster_id" {
  value       = module.capella_audit.capella_cluster_id
  description = "Capella cluster ID"
}

output "csv_query_interval" {
  value       = module.capella_audit.csv_query_interval
  description = "Query interval in seconds"
}

output "universal_connector_enabled" {
  value       = module.capella_audit.universal_connector_enabled
  description = "Whether the Universal Connector is enabled"
}

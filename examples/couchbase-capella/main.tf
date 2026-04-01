#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

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
  capella_api_host        = var.capella_api_host
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

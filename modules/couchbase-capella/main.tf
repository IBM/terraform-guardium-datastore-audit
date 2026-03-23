#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Couchbase Capella Audit Configuration Module
# This module enables audit logging on an existing Capella cluster and integrates with Guardium


resource "couchbase-capella_audit_log_settings" "auditlogsettings" {
  organization_id   = var.capella_organization_id
  project_id        = var.capella_project_id
  cluster_id        = var.capella_cluster_id
  audit_enabled     = var.auditlogsettings.audit_enabled
  enabled_event_ids = var.auditlogsettings.enabled_event_ids
  disabled_users    = var.auditlogsettings.disabled_users
}

locals {
  # Create unique UDC name for this Capella cluster
  udc_name     = format("capella-%s", var.capella_cluster_id)
  api_base_url = format("%s/v4", var.capella_api_host)
  auth_token   = format("Bearer %s", var.capella_api_token)
}


# Universal Connector Configuration Template
locals {
  capella_uc_csv = templatefile("${path.module}/templates/capellaRestApi.tpl", {
    udc_name        = local.udc_name
    organization_id = var.capella_organization_id
    project_id      = var.capella_project_id
    cluster_id      = var.capella_cluster_id
    query_interval  = var.csv_query_interval
    query_length    = var.csv_query_length
    description     = var.csv_description != "" ? var.csv_description : "Guardium connector for Capella cluster ${var.capella_cluster_id}"
    api_base_url    = local.api_base_url
    auth_token      = local.auth_token
  })
}

# resource "local_file" "capella_csv" {
#   content  = local.capella_uc_csv
#   filename = "${path.module}/output/capella.csv"
# }

# Connect datasource to Guardium Universal Connector
module "gdp_connect-datasource-to-uc" {
  source = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  count  = var.enable_universal_connector ? 1 : 0

  udc_name       = local.udc_name
  udc_csv_parsed = local.capella_uc_csv

  # Guardium authentication
  client_id     = var.gdp_client_id
  client_secret = var.gdp_client_secret
  gdp_server    = var.gdp_server
  gdp_port      = var.gdp_port
  gdp_username  = var.gdp_username
  gdp_password  = var.gdp_password
  gdp_mu_host   = var.gdp_mu_host
}

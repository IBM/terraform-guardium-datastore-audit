#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Get GCP project details
data "google_project" "current" {
  project_id = var.gcp_project_id
}

# Get AlloyDB cluster details
data "google_alloydb_cluster" "cluster_metadata" {
  cluster_id = var.alloydb_cluster_id
  location   = var.gcp_region
}

# Module to register AlloyDB with Guardium via Pub/Sub
module "alloydb-pubsub-registration" {
  source = "/Users/nida/GuardiumInsights/Terraform/terraform-guardium-common/modules/alloydb-pubsub-registration"

  # GCP Configuration
  gcp_project_id         = var.gcp_project_id
  gcp_region             = var.gcp_region
  alloydb_cluster_id     = var.alloydb_cluster_id
  pubsub_topic_id        = var.pubsub_topic_id
  pubsub_subscription_id = var.pubsub_subscription_id

  # Guardium Configuration
  udc_gcp_credential         = var.udc_gcp_credential
  gdp_client_id              = var.gdp_client_id
  gdp_client_secret          = var.gdp_client_secret
  gdp_server                 = var.gdp_server
  gdp_port                   = var.gdp_port
  gdp_username               = var.gdp_username
  gdp_password               = var.gdp_password
  gdp_mu_host                = var.gdp_mu_host
  enable_universal_connector = var.enable_universal_connector

  # Pub/Sub Configuration
  csv_start_position = var.csv_start_position
  max_messages       = var.max_messages
}

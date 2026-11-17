#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

/**
 * # UC CSV Import
 *
 * This example imports one or more Universal Connector profile CSV files into IBM
 * Guardium Data Protection and deploys every profile they contain on the specified
 * collector(s).
 *
 * ## Usage
 *
 * Set `csv_file_paths` to a list of existing UC profile CSV file paths. Terraform
 * will upload each file, extract all profile names automatically, and install every
 * connector on every Managed Unit listed in `gdp_mu_host`.
 */

# Configure Guardium Data Protection provider
provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}

module "uc_csv_import" {
  source = "../../modules/uc-csv-import"

  # CSV files — profile names are extracted automatically from each file
  csv_file_paths = var.csv_file_paths

  # Guardium Data Protection Configuration
  gdp_server        = var.gdp_server
  gdp_port          = var.gdp_port
  gdp_username      = var.gdp_username
  gdp_password      = var.gdp_password
  gdp_client_id     = var.gdp_client_id
  gdp_client_secret = var.gdp_client_secret
  gdp_mu_host       = var.gdp_mu_host

  # Universal Connector Control
  enable_universal_connector = var.enable_universal_connector
  test_connections           = var.test_connections
}

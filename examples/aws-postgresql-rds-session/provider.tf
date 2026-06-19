#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Configure Guardium Data Protection provider
provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}
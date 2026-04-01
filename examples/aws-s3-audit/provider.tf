#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Configure the Guardium Data Protection Provider
provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}
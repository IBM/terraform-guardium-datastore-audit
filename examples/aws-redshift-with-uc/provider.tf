#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

# Provider Configuration

# AWS Provider
provider "aws" {
  region = var.aws_region
}

# Guardium Data Protection Provider
provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}
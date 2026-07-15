#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    guardium-data-protection = {
      source  = "IBM/guardium-data-protection"
      version = ">= 1.0.0"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {}
}

provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}

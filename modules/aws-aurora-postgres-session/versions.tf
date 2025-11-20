#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    gdp-middleware-helper = {
      source  = "IBM/gdp-middleware-helper"
      version = "1.2.0"
    }
    guardium-data-protection = {
      source  = "IBM/guardium-data-protection"
      version = "1.1.0"
    }
  }
}
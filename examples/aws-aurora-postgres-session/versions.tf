#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    guardium-data-protection = {
      source = "IBM/guardium-data-protection"
      version = "1.2.0"
    }
    gdp-middleware-helper = {
      source  = "IBM/gdp-middleware-helper"
      version = "1.2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0"
    }
  }
}
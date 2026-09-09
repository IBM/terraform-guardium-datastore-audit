#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    guardium-data-protection = {
      source  = "IBM/guardium-data-protection"
      version = "= 1.5.2"
    }
    gdp-middleware-helper = {
      source  = "IBM/gdp-middleware-helper"
      version = "= 1.5.2"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}

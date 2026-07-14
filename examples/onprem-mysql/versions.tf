#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    gdp-middleware-helper = {
      source  = "IBM/gdp-middleware-helper"
      version = ">= 1.0.0"
    }
    guardium-data-protection = {
      source  = "IBM/guardium-data-protection"
      version = ">= 1.0.0"
    }
  }
}

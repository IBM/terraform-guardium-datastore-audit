#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    guardium-data-protection = {
      source = "IBM/guardium-data-protection"
    }
    gdp-middleware-helper = {
      source = "IBM/gdp-middleware-helper"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.26.0"
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

#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

# Terraform and Provider Version Requirements

terraform {
  required_version = ">= 0.13"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
    guardium-data-protection = {
      source  = "IBM/guardium-data-protection"
      version = ">= 1.0.0"
    }
  }
}
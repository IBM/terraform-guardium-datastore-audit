terraform {
  required_version = ">= 0.13"
  required_providers {
    local = {
      source = "hashicorp/local"
    }
    archive = {
      source = "hashicorp/archive"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.26.0"
    }

    guardium-data-protection = {
      source = "IBM/guardium-data-protection"
    }

    gdp-middleware-helper = {
      source  = "IBM/gdp-middleware-helper"
      version = ">= 1.0.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}





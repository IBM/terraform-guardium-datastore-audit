terraform {
  required_version = ">= 0.13"
  required_providers {
    local = {
      source = "hashicorp/local"
    }
    archive = {
      source = "hashicorp/archive"
    }

    gdp-middleware-helper = {
      source  = "IBM/gdp-middleware-helper"
      version = ">= 1.0.0"
    }

    guardium-data-protection = {
      source  = "IBM/guardium-data-protection"
      version = ">= 1.0.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

provider "guardium-data-protection" {
  host = var.gdp_server
  port = var.gdp_port
}

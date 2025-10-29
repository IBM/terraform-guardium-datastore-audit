terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    guardium-data-protection = {
      source  = "IBM/guardium-data-protection"
      version = ">= 1.0.0"
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

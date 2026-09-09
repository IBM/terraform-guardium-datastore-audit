terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    guardium-data-protection = {
      source = "IBM/guardium-data-protection"
    }
  }
}

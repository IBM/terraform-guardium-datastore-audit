terraform {
  required_version = ">= 1.3"
  required_providers {
    guardium-data-protection = {
      source  = "IBM/guardium-data-protection"
      version = ">= 1.1.0"
    }
  }
}
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  
  # Default tags applied to ALL resources
  default_tags {
    tags = merge(
      var.common_tags,
      {
        Region    = var.aws_region
        Terraform = "true"
      }
    )
  }
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# Data source to get current region
data "aws_region" "current" {}

# Data source for availability zones in the region
data "aws_availability_zones" "available" {
  state = "available"
}

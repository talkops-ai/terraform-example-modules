terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-vpc-us-east-1"
    # Using environment-first, platform-owned production state
    # Key pattern (resolved for this primary prod state): vpc/prod/platform/terraform.tfstate
    key            = "vpc/prod/platform/terraform.tfstate"
    region         = "us-east-1"

    # Encryption and locking
    encrypt        = true
    kms_key_id     = "alias/terraform-state-kms-us-east-1"
    dynamodb_table = "terraform-state-locks-vpc"

    # Note: Additional backend settings (profile, role_arn) can be set via -backend-config during terraform init
  }
}

provider "aws" {
  region = "us-east-1"

  # Recommended runtime hardening
  # - Use a dedicated IAM principal or assumed role for CI and interactive runs
  # - Prefer short-lived credentials (STS AssumeRole) for cross-account deployments
  default_tags {
    tags = {
      Service      = "vpc"
      Environment  = "prod"
      Generated_By = "e078d8dc-d434-458b-858b-70406fd1c9f1"
    }
  }

  # Optional settings to consider (uncomment / configure when required):
  # max_retries = 5
  # retry_mode  = "standard"
}
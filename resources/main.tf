terraform {
  backend "s3" {
    bucket = "pamit-bucket"
    key    = "ruby-event-bridge/terraform-state/terraform.tfstate"
    region = "ap-southeast-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-southeast-2"

  # # LocalStack endpoint for local development
  # access_key                  = "test"
  # secret_key                  = "test"
  # skip_credentials_validation = true
  # skip_requesting_account_id  = true
  # endpoints {
  #   sqs       = "http://localhost:4566"
  #   sns       = "http://localhost:4566"
  #   schemas   = "http://localhost:4566"
  # }
}

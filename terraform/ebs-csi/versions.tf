terraform {
  backend "s3" {
    bucket = "aws-terraform-remote-state-bucket"
    key    = "ebs/terraform.tfstate"
    region = "us-east-1"

  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.53.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.8.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

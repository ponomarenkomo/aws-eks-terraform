terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.51.0"
    }
  }

  backend "s3" {
    bucket = "aws-terraform-remote-state-bucket"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"

  }
}

provider "aws" {
  region = var.aws_region

}


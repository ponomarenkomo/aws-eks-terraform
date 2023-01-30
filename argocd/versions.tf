terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.8.0"
    }

    github = {
      source  = "integrations/github"
      version = "5.16.0"
    }
  }

  backend "s3" {
    bucket = "aws-terraform-remote-state-bucket"
    key    = "argocd/terraform.tfstate"
    region = "us-east-1"

  }
}


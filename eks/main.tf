terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.51.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.17.0"
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

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks_cluster.name]
    command     = "aws"
  }

}



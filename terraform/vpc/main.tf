terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.51.0"
    }
  }
  backend "s3" {
    bucket = "aws-terraform-remote-state-bucket"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"

  }
}

provider "aws" {
  region = var.aws_region

}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name           = "eks-vpc"
  cidr           = var.eks_vpc_cidr
  azs            = data.aws_availability_zones.available.names
  public_subnets = var.eks_public_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Type                                = "Public Subnets"
    "kubernetes.io/role/elb"            = 1
    "kubernetes.io/cluster/eks-cluster" = "shared"
  }
}

data "aws_availability_zones" "available" {
  state = "available"

}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks-cluster"
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_master_role.arn
  vpc_config {
    endpoint_public_access = true
    subnet_ids             = data.terraform_remote_state.vpc.outputs.public_subnet_ids
    public_access_cidrs    = var.cluster_endpoint_public_access_cidrs
  }
  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

  # Enable EKS Cluster Control Plane Logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]

}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "aws-terraform-remote-state-bucket"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }

}



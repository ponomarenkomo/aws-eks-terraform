data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "aws-terraform-remote-state-bucket"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.kubeconfig_certificate_authority_data)


    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_name]

    }
  }
}

provider "github" {
  token = var.token
}

locals {
  argocd = {
    github_public_repo_name = "ponomarenkomo/aws-eks-terraform"
    version                 = "5.4.0"
    namespace               = "argocd"
  }
}

variable "hosted_zone" {
  default = null
  type    = string

}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm/"
  chart            = "argo-cd"
  version          = local.argocd.version
  namespace        = local.argocd.namespace
  create_namespace = true


  values = [
    templatefile("../templates/values.yaml", {
      k8s_repo = local.argocd.github_public_repo_name,
      host     = var.hosted_zone
    })
  ]

}

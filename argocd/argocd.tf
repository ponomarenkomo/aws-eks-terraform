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
  hosted_zone = "kubxr.com"
  argocd = {
    gitlab_private_repo_name = "bakavets/k8s-demo"
    version                  = "5.4.0"
    namespace                = "argocd"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = local.argocd.version
  namespace        = local.argocd.namespace
  create_namespace = true

  #   values = [
  # templatefile("${path.module}/templates/values.yaml", {
  #   k8s_ssh_private_key = tls_private_key.ed25519_argocd.private_key_openssh,
  #   k8s_repo            = local.argocd.gitlab_private_repo_name,
  #   host                = local.hosted_zone
  # })
  #   ]

}

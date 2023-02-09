locals {
  argocd = {
    github_public_repo_name = "ponomarenkomo/aws-eks-terraform"
    version                 = "5.4.0"
    namespace               = "argocd"
  }

  initial_bootstrap = {
    path           = "kubernetes/infrastructure/templates/"
    repoURL        = "git@github.com:${local.argocd.github_public_repo_name}.git",
    targetRevision = "main",
    acme_email     = "ponomarenko.n.2001@gmail.com"
  }
}

locals {
  cert_manager = {
    name      = "cert-manager"
    namespace = "cert-manager"
  }

  external_dns = {
    name      = "irsa-external-dns-sa"
    namespace = "external-dns"
  }

  aws_load_balancer_controller = {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
  }
}

locals {
  cluster_name = data.terraform_remote_state.eks.outputs.cluster_name
}

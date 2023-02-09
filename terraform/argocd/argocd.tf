data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "aws-terraform-remote-state-bucket"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm/"
  chart            = "argo-cd"
  version          = local.argocd.version
  namespace        = local.argocd.namespace
  create_namespace = true


  # k8s_repo = local.argocd.github_public_repo_name,
  values = [
    templatefile("${path.module}/templates/values.yaml", {
      k8s_repo = local.argocd.github_public_repo_name
      host     = var.hosted_zone
    })
  ]
}



resource "tls_private_key" "ed25519_argocd" {
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "argocd-deploy-key" {
  title      = "ArgoCD Deploy key for deployment"
  repository = local.argocd.github_public_repo_name
  key        = tls_private_key.ed25519_argocd.public_key_openssh
}



data "aws_route53_zone" "zone" {
  name         = var.hosted_zone
  private_zone = false
}

resource "kubectl_manifest" "initial_bootstrap" {
  yaml_body = templatefile("${path.module}/templates/infra-project.yaml", {
    namespace      = local.argocd.namespace,
    path           = local.initial_bootstrap.path,
    repoURL        = local.initial_bootstrap.repoURL,
    targetRevision = local.initial_bootstrap.targetRevision,

    aws_region               = var.aws_region,
    aws_route53_dnsZone      = var.hosted_zone,
    aws_route53_hostedZoneID = data.aws_route53_zone.zone.zone_id,

    clusterName = local.cluster_name,

    source_repoURL        = local.initial_bootstrap.repoURL,
    source_targetRevision = local.initial_bootstrap.targetRevision,

    bootstrapApp_certManager_serviceAccountName      = local.cert_manager.name,
    bootstrapApp_certManager_serviceAccountNamespace = local.cert_manager.namespace,
    bootstrapApp_certManager_eksRoleArn              = module.irsa_cert_manager.iam_role_arn,

    bootstrapApp_certManagerConfigs_acme_email = local.initial_bootstrap.acme_email,

    bootstrapApp_awsLBController_serviceAccountName = local.aws_load_balancer_controller.name,
    bootstrapApp_awsLBController_namespace          = local.aws_load_balancer_controller.namespace,
    bootstrapApp_awsLBController_eksRoleArn         = module.irsa_lb_role.iam_role_arn,

    bootstrapApp_externalDNS_serviceAccountName = local.external_dns.name,
    bootstrapApp_externalDNS_namespace          = local.external_dns.namespace,
    bootstrapApp_externalDNS_eksRoleArn         = module.irsa_external_dns_role.iam_role_arn
  })

  depends_on = [
    helm_release.argocd,
    # github_repository_deploy_key.argocd-deploy-key
  ]
}

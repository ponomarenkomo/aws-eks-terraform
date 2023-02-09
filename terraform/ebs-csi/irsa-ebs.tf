data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "aws-terraform-remote-state-bucket"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}

data "http" "ebs_csi_driver_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/docs/example-iam-policy.json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  ebs_csi = {
    name      = "ebs-csi"
    namespace = "kube-system"
  }
}

module "irsa_ebs_csi" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role      = true
  role_name        = "${local.ebs_csi.name}-role"
  role_policy_arns = [aws_iam_policy.ebs_csi_iam_policy.arn]
  # provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.ebs_csi.namespace}:${local.ebs_csi.name}"]
}

resource "aws_iam_policy" "ebs_csi_iam_policy" {
  name        = "AmazonEKS_EBS_CSI_Driver_Policy"
  path        = "/"
  description = "EBS CSI IAM Policy"
  policy      = data.http.ebs_csi_driver_policy.body

}


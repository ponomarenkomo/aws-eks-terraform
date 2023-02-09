data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}



module "irsa_lb_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role                   = true
  role_name                     = local.aws_load_balancer_controller.name
  role_policy_arns              = [aws_iam_policy.ebs_csi_iam_policy.arn]
  provider_url                  = data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.aws_load_balancer_controller.namespace}:${local.aws_load_balancer_controller.name}"]

}


resource "aws_iam_policy" "ebs_csi_iam_policy" {
  name        = "AmazonEKS_EBS_CSI_Driver_Policy"
  path        = "/"
  description = "EBS CSI IAM Policy"
  policy      = data.http.lbc_iam_policy.body

}

output "lbc_iam_policy" {
  value = data.http.lbc_iam_policy.body
}

output "lbc_iam_role_arn" {
  description = "AWS Load Balancer Controller IAM Role ARN"
  value       = module.irsa_lb_role.iam_role_arn
}




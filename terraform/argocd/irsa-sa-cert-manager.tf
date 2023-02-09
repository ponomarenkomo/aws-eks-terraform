module "irsa_cert_manager" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role                   = true
  role_name                     = local.cert_manager.name
  role_policy_arns              = [aws_iam_policy.cert_manager_policy.arn]
  provider_url                  = data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.cert_manager.namespace}:${local.cert_manager.name}"]

}

resource "aws_iam_policy" "cert_manager_policy" {
  name        = "${local.cluster_name}-cert-manager-policy"
  description = "EKS AWS Cert Manager policy for cluster}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/${data.aws_route53_zone.zone.zone_id}"
    }
  ]
}
EOF
}



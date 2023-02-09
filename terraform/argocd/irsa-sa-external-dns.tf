module "irsa_external_dns_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role                   = true
  role_name                     = local.external_dns.name
  role_policy_arns              = [aws_iam_policy.external_dns_policy.arn]
  provider_url                  = data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.external_dns.namespace}:${local.external_dns.name}"]

}

resource "aws_iam_policy" "external_dns_policy" {
  name        = "external-dns-policy"
  description = "EKS AWS ExternalDNS policy for cluster"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

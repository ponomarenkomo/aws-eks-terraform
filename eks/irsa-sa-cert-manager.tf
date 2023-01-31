resource "kubernetes_service_account_v1" "cert_manager" {
  depends_on = [aws_iam_role_policy_attachment.cert_manager_policy_attachment, aws_eks_node_group.eks_ng_public]
  metadata {
    name = "irsa-cert-manager-sa"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cert_manager_role.arn
    }
  }
}


resource "aws_iam_role" "cert_manager_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.oidc_provider.arn}"
        }
        Condition = {
          StringEquals = {
            "${local.aws_iam_oidc_connect_provider_extract_from_arn}:sub" : "system:serviceaccount:default:cert_manager"
          }
        }

      },
    ]
  })
}

locals {
  cluster_name = aws_eks_cluster.eks_cluster.name
}

data "aws_route53_zone" "zone" {
  name         = var.hosted_zone
  private_zone = false
}

resource "aws_iam_policy" "cert_manager_policy" {
  name        = "${local.cluster_name}-cert-manager-policy"
  description = "EKS AWS Cert Manager policy for cluster ${local.cluster_name}"

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

resource "aws_iam_role_policy_attachment" "cert_manager_policy_attachment" {
  policy_arn = aws_iam_policy.cert_manager_policy.arn
  role       = aws_iam_role.cert_manager_role.name

}

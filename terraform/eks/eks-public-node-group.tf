resource "aws_eks_node_group" "eks_ng_public" {

  node_group_name = "public-ng"
  version         = var.cluster_version
  cluster_name    = aws_eks_cluster.eks_cluster.id

  instance_types = ["t2.medium"]
  node_role_arn  = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids     = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  update_config {
    max_unavailable = 1

  }

  ami_type      = "AL2_x86_64"
  capacity_type = "ON_DEMAND"
  disk_size     = 40

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy
  ]
}

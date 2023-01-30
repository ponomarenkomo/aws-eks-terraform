output "cluster_endpoint" {
  description = "Kubernetes endpoint for Helm"
  value       = aws_eks_cluster.eks_cluster.endpoint

}

output "kubeconfig_certificate_authority_data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_name" {
  description = "Cluster name for Helm auth"
  value       = aws_eks_cluster.eks_cluster.name

}

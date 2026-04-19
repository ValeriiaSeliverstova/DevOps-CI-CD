output "cluster_name" {
  description = "Назва EKS кластера"
  value       = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  description = "Endpoint EKS кластера"
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_arn" {
  description = "ARN EKS кластера"
  value       = aws_eks_cluster.eks.arn
}

output "node_group_name" {
  description = "Назва node group"
  value       = aws_eks_node_group.default.node_group_name
}

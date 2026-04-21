# output "s3_bucket_url" {
#   description = "Назва S3-бакета для стейтів"
#   value       = module.s3_backend.s3_bucket_url
# }

# output "dynamodb_table_name" {
#   description = "Назва таблиці DynamoDB для блокування стейтів"
#   value       = module.s3_backend.dynamodb_table_name
# }

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ecr_repository_arn" {
  value = module.ecr.repository_arn
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}

output "nat_gateway_id" {
  value = module.vpc.nat_gateway_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_node_group_name" {
  value = module.eks.node_group_name
}

output "kubectl_config_command" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "jenkins_namespace" {
  value = module.jenkins.namespace
}

output "argocd_namespace" {
  value = module.argo_cd.namespace
}

output "jenkins_agent_role_arn" {
  value = module.jenkins.agent_role_arn
}

output "jenkins_url" {
  value = module.jenkins.service_url
}

output "jenkins_admin_username" {
  value = module.jenkins.admin_username
}

output "jenkins_admin_password" {
  value     = module.jenkins.admin_password
  sensitive = true
}

output "argocd_url" {
  value = module.argo_cd.server_url
}

output "argocd_initial_admin_password" {
  value     = module.argo_cd.initial_admin_password
  sensitive = true
}

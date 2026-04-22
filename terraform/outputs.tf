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

output "rds_endpoint" {
  value = var.enable_rds ? module.rds[0].endpoint : null
}

output "rds_reader_endpoint" {
  value = var.enable_rds ? module.rds[0].reader_endpoint : null
}

output "rds_security_group_id" {
  value = var.enable_rds ? module.rds[0].security_group_id : null
}

output "rds_parameter_group_name" {
  value = var.enable_rds ? module.rds[0].parameter_group_name : null
}

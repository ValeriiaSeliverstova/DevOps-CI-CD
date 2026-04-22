output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.default.name
}

output "security_group_id" {
  description = "Security group ID used by the database"
  value       = aws_security_group.rds.id
}

output "parameter_group_name" {
  description = "Parameter group name for regular RDS or cluster parameter group for Aurora"
  value       = var.use_aurora ? aws_rds_cluster_parameter_group.aurora[0].name : aws_db_parameter_group.standard[0].name
}

output "endpoint" {
  description = "Main database endpoint"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.standard[0].address
}

output "reader_endpoint" {
  description = "Aurora reader endpoint. Null for regular RDS."
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].reader_endpoint : null
}

output "port" {
  description = "Database port"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].port : aws_db_instance.standard[0].port
}

output "resource_id" {
  description = "Cluster identifier for Aurora or instance identifier for regular RDS"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].cluster_identifier : aws_db_instance.standard[0].identifier
}

output "engine" {
  description = "Selected database engine"
  value       = var.engine
}

output "use_aurora" {
  description = "Whether Aurora is enabled"
  value       = var.use_aurora
}

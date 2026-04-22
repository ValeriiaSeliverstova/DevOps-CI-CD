resource "aws_rds_cluster" "aurora" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier              = "${var.name}-cluster"
  engine                          = var.engine_cluster
  engine_version                  = var.engine_version_cluster
  master_username                 = var.username
  master_password                 = var.password
  database_name                   = var.db_name
  db_subnet_group_name            = aws_db_subnet_group.default.name
  vpc_security_group_ids          = [aws_security_group.rds.id]
  backup_retention_period         = var.backup_retention_period == "" ? null : tonumber(var.backup_retention_period)
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = var.skip_final_snapshot ? null : "${var.name}-final-snapshot"
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora[0].name
  deletion_protection             = var.deletion_protection
  storage_encrypted               = var.storage_encrypted
  apply_immediately               = var.apply_immediately
  port                            = var.port

  lifecycle {
    precondition {
      condition     = contains(["aurora-postgresql", "aurora-mysql"], var.engine_cluster)
      error_message = "When use_aurora = true, engine_cluster must be aurora-postgresql or aurora-mysql."
    }
  }

  tags = var.tags
}

resource "aws_rds_cluster_instance" "aurora_writer" {
  count = var.use_aurora ? 1 : 0

  identifier          = "${var.name}-writer"
  cluster_identifier  = aws_rds_cluster.aurora[0].id
  instance_class      = var.instance_class
  engine              = var.engine_cluster
  engine_version      = var.engine_version_cluster
  publicly_accessible = var.publicly_accessible

  tags = var.tags
}

resource "aws_rds_cluster_instance" "aurora_readers" {
  count = var.use_aurora ? var.aurora_replica_count : 0

  identifier          = "${var.name}-reader-${count.index}"
  cluster_identifier  = aws_rds_cluster.aurora[0].id
  instance_class      = var.instance_class
  engine              = var.engine_cluster
  engine_version      = var.engine_version_cluster
  publicly_accessible = var.publicly_accessible

  tags = var.tags
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  count       = var.use_aurora ? 1 : 0
  name        = "${var.name}-aurora-params"
  family      = local.effective_family_aurora
  description = "Aurora PG for ${var.name}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = "pending-reboot"
    }
  }

  lifecycle {
    precondition {
      condition     = local.effective_family_aurora != null
      error_message = "Could not detect Aurora parameter group family automatically. Please set parameter_group_family_aurora explicitly."
    }
  }

  tags = var.tags
}

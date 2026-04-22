locals {
  major_version_rds    = regex("^([0-9]+(?:\\.[0-9]+)?)", var.engine_version)[0]
  major_version_aurora = regex("^([0-9]+(?:\\.[0-9]+)?)", var.engine_version_cluster)[0]

  family_map = {
    "postgres:14"          = "postgres14"
    "postgres:15"          = "postgres15"
    "postgres:16"          = "postgres16"
    "mysql:8.0"            = "mysql8.0"
    "mysql:8"              = "mysql8.0"
    "aurora-postgresql:14" = "aurora-postgresql14"
    "aurora-postgresql:15" = "aurora-postgresql15"
    "aurora-postgresql:16" = "aurora-postgresql16"
    "aurora-mysql:8.0"     = "aurora-mysql8.0"
    "aurora-mysql:8"       = "aurora-mysql8.0"
    "aurora-mysql:5.7"     = "aurora-mysql5.7"
  }

  selected_subnet_ids = var.publicly_accessible && length(var.subnet_public_ids) > 0 ? var.subnet_public_ids : var.subnet_private_ids

  detected_family_rds    = lookup(local.family_map, "${var.engine}:${local.major_version_rds}", null)
  detected_family_aurora = lookup(local.family_map, "${var.engine_cluster}:${local.major_version_aurora}", null)

  effective_family_rds = coalesce(
    var.parameter_group_family_rds,
    local.detected_family_rds
  )

  effective_family_aurora = coalesce(
    var.parameter_group_family_aurora,
    local.detected_family_aurora
  )

  engine_parameters = [
    for name, value in var.parameters : {
      name         = name
      value        = value
      apply_method = name == "max_connections" ? "pending-reboot" : "immediate"
    }
  ]
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.name}-subnet-group"
  subnet_ids = local.selected_subnet_ids

  lifecycle {
    precondition {
      condition     = var.publicly_accessible ? length(var.subnet_public_ids) > 0 : length(var.subnet_private_ids) > 0
      error_message = "Please provide public subnets when publicly_accessible = true, or private subnets when publicly_accessible = false."
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-subnet-group"
  })
}

resource "aws_security_group" "rds" {
  name        = "${var.name}-sg"
  description = "Security group for ${var.name} database"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_cidr_blocks
    content {
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  dynamic "ingress" {
    for_each = var.allowed_security_group_ids
    content {
      from_port       = var.port
      to_port         = var.port
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-sg"
  })
}

resource "aws_db_parameter_group" "standard" {
  count       = var.use_aurora ? 0 : 1
  name        = "${var.name}-rds-params"
  family      = local.effective_family_rds
  description = "Standard RDS PG for ${var.name}"

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
      condition     = local.effective_family_rds != null
      error_message = "Could not detect RDS parameter group family automatically. Please set parameter_group_family_rds explicitly."
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-rds-params"
  })
}

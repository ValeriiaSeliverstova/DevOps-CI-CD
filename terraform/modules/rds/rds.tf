resource "aws_db_instance" "standard" {
  count = var.use_aurora ? 0 : 1

  identifier              = var.name
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  storage_type            = var.storage_type
  db_name                 = var.db_name
  username                = var.username
  password                = var.password
  port                    = var.port
  multi_az                = var.multi_az
  publicly_accessible     = var.publicly_accessible
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  parameter_group_name    = aws_db_parameter_group.standard[0].name
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection
  apply_immediately       = var.apply_immediately
  storage_encrypted       = var.storage_encrypted

  lifecycle {
    precondition {
      condition     = contains(["postgres", "mysql"], var.engine)
      error_message = "When use_aurora = false, engine must be postgres or mysql."
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

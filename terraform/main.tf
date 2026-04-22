provider "aws" {
  region = var.aws_region
}

# Підключаємо модуль S3 та DynamoDB
# module "s3_backend" {
#   source = "./modules/s3-backend"
#   bucket_name = "terraform-state-bucket-goit-valeriia-seliverstova"
#   table_name  = "terraform-locks"
# }

# Підключаємо модуль VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_name           = "goit-vpc"
}

# Підключаємо модуль ECR
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "goit-ecr"
  scan_on_push = true
}

module "eks" {
  source              = "./modules/eks"
  cluster_name        = "goit-eks"
  subnet_ids          = module.vpc.private_subnets
  node_subnet_ids     = module.vpc.private_subnets
  node_instance_types = ["t3.small"]
  node_desired_size   = 3
  node_min_size       = 2
  node_max_size       = 3
}

module "rds" {
  count  = var.enable_rds ? 1 : 0
  source = "./modules/rds"

  name                          = var.rds_name
  use_aurora                    = var.rds_use_aurora
  engine_cluster                = var.rds_engine_cluster
  aurora_replica_count          = var.rds_aurora_replica_count
  engine                        = var.rds_engine
  engine_version_cluster        = var.rds_engine_version_cluster
  engine_version                = var.rds_engine_version
  instance_class                = var.rds_instance_class
  allocated_storage             = var.rds_allocated_storage
  db_name                       = var.rds_db_name
  username                      = var.rds_username
  password                      = var.rds_password
  subnet_private_ids            = module.vpc.private_subnets
  subnet_public_ids             = module.vpc.public_subnets
  publicly_accessible           = var.rds_publicly_accessible
  vpc_id                        = module.vpc.vpc_id
  allowed_cidr_blocks           = var.rds_allowed_cidr_blocks
  allowed_security_group_ids    = var.rds_allowed_security_group_ids
  multi_az                      = var.rds_multi_az
  backup_retention_period       = var.rds_backup_retention_period
  storage_type                  = var.rds_storage_type
  skip_final_snapshot           = var.rds_skip_final_snapshot
  deletion_protection           = var.rds_deletion_protection
  apply_immediately             = var.rds_apply_immediately
  storage_encrypted             = var.rds_storage_encrypted
  parameter_group_family_rds    = var.rds_parameter_group_family_rds
  parameter_group_family_aurora = var.rds_parameter_group_family_aurora
  parameters                    = var.rds_parameters

  tags = {
    Project = "goit"
    Module  = "rds"
  }
}

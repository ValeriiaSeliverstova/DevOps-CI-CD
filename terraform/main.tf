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
  source          = "./modules/eks"
  cluster_name    = "goit-eks"
  subnet_ids      = module.vpc.private_subnets
  node_subnet_ids = module.vpc.private_subnets
  node_instance_types = ["t3.small"]
  node_desired_size   = 3
  node_min_size       = 2
  node_max_size       = 3
}

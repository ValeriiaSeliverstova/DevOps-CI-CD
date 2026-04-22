variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-west-2"
}

variable "enable_rds" {
  description = "If true, create the RDS or Aurora module from the root Terraform config"
  type        = bool
  default     = false
}

variable "rds_name" {
  description = "Base name for RDS resources"
  type        = string
  default     = "goit-db"
}

variable "rds_use_aurora" {
  description = "If true, create Aurora. If false, create regular RDS."
  type        = bool
  default     = false
}

variable "rds_engine" {
  description = "Database engine for the RDS module"
  type        = string
  default     = "postgres"
}

variable "rds_engine_cluster" {
  description = "Aurora engine for the RDS module"
  type        = string
  default     = "aurora-postgresql"
}

variable "rds_engine_version" {
  description = "Database engine version for the RDS module"
  type        = string
  default     = "14.22"
}

variable "rds_engine_version_cluster" {
  description = "Aurora engine version for the RDS module"
  type        = string
  default     = "15.3"
}

variable "rds_instance_class" {
  description = "Instance class for the RDS module"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_db_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "rds_username" {
  description = "Master username for the database"
  type        = string
  default     = "dbadmin"
}

variable "rds_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
  default     = "change-me-db-password"
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ for regular RDS instance"
  type        = bool
  default     = false
}

variable "rds_publicly_accessible" {
  description = "Whether the database should be public"
  type        = bool
  default     = false
}

variable "rds_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the database"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "rds_allocated_storage" {
  description = "Allocated storage for regular RDS instance"
  type        = number
  default     = 20
}

variable "rds_storage_type" {
  description = "Storage type for regular RDS instance"
  type        = string
  default     = "gp3"
}

variable "rds_backup_retention_period" {
  description = "How many days to keep automatic backups"
  type        = string
  default     = "7"
}

variable "rds_aurora_replica_count" {
  description = "Number of Aurora reader replicas"
  type        = number
  default     = 1
}

variable "rds_parameter_group_family_rds" {
  description = "Optional manual parameter group family override for regular RDS"
  type        = string
  default     = "postgres14"
}

variable "rds_parameter_group_family_aurora" {
  description = "Optional manual parameter group family override for Aurora"
  type        = string
  default     = "aurora-postgresql15"
}

variable "rds_parameters" {
  description = "Map of DB parameters that should be added to the parameter group"
  type        = map(string)
  default = {
    max_connections = "100"
  }
}

variable "rds_allowed_security_group_ids" {
  description = "Security groups allowed to connect to the database"
  type        = list(string)
  default     = []
}

variable "rds_skip_final_snapshot" {
  description = "Skip final snapshot when deleting the database"
  type        = bool
  default     = true
}

variable "rds_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "rds_apply_immediately" {
  description = "Apply database changes immediately"
  type        = bool
  default     = true
}

variable "rds_storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

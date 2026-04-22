variable "name" {
  description = "Назва інстансу або кластера"
  type        = string
}

variable "engine" {
  type    = string
  default = "postgres"
}

variable "engine_cluster" {
  type    = string
  default = "aurora-postgresql"
}

variable "aurora_replica_count" {
  type    = number
  default = 1
}

variable "engine_version" {
  type    = string
  default = "14.22"
}

variable "engine_version_cluster" {
  type    = string
  default = "15.3"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "vpc_id" {
  type = string
}

variable "subnet_private_ids" {
  type = list(string)
}

variable "subnet_public_ids" {
  type = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the database"
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to connect to the database"
  type        = list(string)
  default     = []
}

variable "publicly_accessible" {
  type    = bool
  default = false
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "storage_type" {
  description = "Storage type for regular RDS"
  type        = string
  default     = "gp3"
}

variable "backup_retention_period" {
  type    = string
  default = ""
}

variable "parameter_group_family_rds" {
  type    = string
  default = "postgres15"
}

variable "parameter_group_family_aurora" {
  type    = string
  default = "aurora-postgresql15"
}

variable "parameters" {
  type    = map(string)
  default = {}
}

variable "use_aurora" {
  type    = bool
  default = false
}

variable "port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on delete"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply DB changes immediately"
  type        = bool
  default     = true
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to created resources"
  type        = map(string)
  default     = {}
}

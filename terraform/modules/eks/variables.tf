variable "cluster_name" {
  description = "Назва EKS кластера"
  type        = string
}

variable "subnet_ids" {
  description = "Список subnet IDs для control plane EKS"
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "Список subnet IDs для worker nodes"
  type        = list(string)
}

variable "node_instance_types" {
  description = "Типи інстансів для worker nodes"
  type        = list(string)
  default     = ["t3.micro"]
}

variable "node_desired_size" {
  description = "Бажана кількість worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Мінімальна кількість worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Максимальна кількість worker nodes"
  type        = number
  default     = 3
}

variable "capacity_type" {
  description = "Тип capacity для node group"
  type        = string
  default     = "ON_DEMAND"
}

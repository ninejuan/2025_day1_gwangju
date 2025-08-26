variable "project" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS cluster"
  type        = list(string)
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.32"
}

variable "app_instance_type" {
  description = "Instance type for app node group"
  type        = string
  default     = "t3.medium"
}

variable "addon_instance_type" {
  description = "Instance type for addon node group"
  type        = string
  default     = "t3.medium"
} 
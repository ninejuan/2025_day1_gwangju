variable "project" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for RDS"
  type        = string
}

variable "data_subnet_ids" {
  description = "Data subnet IDs for RDS"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for RDS Proxy"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to access RDS"
  type        = list(string)
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "day1"
}

variable "master_username" {
  description = "Master username for database"
  type        = string
  default     = "admin"
}

variable "master_password" {
  description = "Master password for database"
  type        = string
  default     = "Skills53#$%"
  sensitive   = true
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 3309
} 
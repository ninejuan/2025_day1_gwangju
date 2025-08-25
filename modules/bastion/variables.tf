variable "project" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for bastion host"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for bastion host"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for bastion host"
  type        = string
  default     = "t3.medium"
}

variable "ssh_port" {
  description = "SSH port for bastion host"
  type        = number
  default     = 2222
} 
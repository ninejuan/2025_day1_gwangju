variable "project" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr_blocks" {
  description = "VPC CIDR blocks"
  type        = map(string)
}

variable "subnet_cidr_blocks" {
  description = "Subnet CIDR blocks"
  type        = map(map(string))
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
} 
variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "firewall_subnet_id" {
  description = "Firewall subnet ID"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
} 

variable "app_vpc_id" {
  description = "App VPC ID"
  type        = string
}

variable "app_firewall_subnet_ids" {
  description = "App firewall subnet IDs"
  type        = list(string)
}
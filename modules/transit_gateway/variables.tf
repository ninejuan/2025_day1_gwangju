variable "project" {
  description = "Project name"
  type        = string
}

variable "hub_vpc_id" {
  description = "Hub VPC ID"
  type        = string
}

variable "app_vpc_id" {
  description = "Application VPC ID"
  type        = string
}

variable "hub_subnet_ids" {
  description = "Hub subnet IDs for Transit Gateway attachment"
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "Application subnet IDs for Transit Gateway attachment"
  type        = list(string)
}

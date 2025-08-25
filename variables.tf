variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "gj2025"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "github_token" {
  description = "GitHub access token"
  type        = string
  sensitive   = true
}

variable "github_username" {
  description = "GitHub username"
  type        = string
}

variable "codestar_connection_arn" {
  description = "CodeStar connection ARN for GitHub"
  type        = string
  default     = ""
}

variable "repository_id" {
  description = "GitHub repository ID"
  type        = string
  default     = "gj2025-repository"
}

variable "vpc_cidr_blocks" {
  description = "VPC CIDR blocks"
  type        = map(string)
  default = {
    hub = "10.0.0.0/16"
    app = "192.168.0.0/16"
  }
}

variable "subnet_cidr_blocks" {
  description = "Subnet CIDR blocks"
  type        = map(map(string))
  default = {
    hub = {
      public_a     = "10.0.0.0/24"
      public_b     = "10.0.1.0/24"
      private_a    = "10.0.2.0/24"
      private_b    = "10.0.3.0/24"
      firewall     = "10.0.4.0/24"
    }
    app = {
      private_a    = "192.168.0.0/24"
      private_b    = "192.168.1.0/24"
      data_a       = "192.168.2.0/24"
      data_b       = "192.168.3.0/24"
    }
  }
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

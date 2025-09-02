variable "project" {
  description = "Project name"
  type        = string
}

variable "app_name" {
  description = "Application name (red or green)"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN"
  type        = string
}

variable "github_token_arn" {
  description = "GitHub token secret ARN"
  type        = string
}

variable "artifacts_bucket_arn" {
  description = "S3 artifacts bucket ARN"
  type        = string
}

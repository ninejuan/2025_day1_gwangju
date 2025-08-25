variable "project" {
  description = "Project name"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "artifact_bucket_arn" {
  description = "Artifact bucket ARN"
  type        = string
}

variable "codestar_connection_arn" {
  description = "CodeStar connection ARN"
  type        = string
}

variable "repository_id" {
  description = "Repository ID"
  type        = string
}

variable "source_branch" {
  description = "Source branch"
  type        = string
}

variable "codebuild_project_name" {
  description = "CodeBuild project name"
  type        = string
}

variable "github_token" {
  description = "GitHub token"
  type        = string
}

variable "github_username" {
  description = "GitHub username"
  type        = string
}

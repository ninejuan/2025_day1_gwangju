variable "project" {
  description = "Project name"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "oidc_provider" {
  description = "EKS OIDC Provider URL (without https://)"
  type        = string
}

variable "secret_arns" {
  description = "List of Secrets Manager secret ARNs"
  type        = list(string)
  default     = []
}

variable "kms_key_arns" {
  description = "List of KMS key ARNs"
  type        = list(string)
  default     = []
}

variable "app_secrets_arn" {
  description = "App secrets ARN from Secrets Manager"
  type        = string
}

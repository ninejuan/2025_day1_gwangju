output "external_secrets_role_arn" {
  description = "External Secrets IAM role ARN"
  value       = aws_iam_role.external_secrets.arn
}

output "external_secrets_role_name" {
  description = "External Secrets IAM role name"
  value       = aws_iam_role.external_secrets.name
}

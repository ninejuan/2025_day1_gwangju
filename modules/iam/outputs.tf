output "external_secrets_role_arn" {
  description = "External Secrets IAM role ARN"
  value       = aws_iam_role.external_secrets.arn
}

output "external_secrets_role_name" {
  description = "External Secrets IAM role name"
  value       = aws_iam_role.external_secrets.name
}

output "external_secrets_policy_arn" {
  description = "External Secrets IAM policy ARN"
  value       = aws_iam_policy.external_secrets.arn
}

output "fluent_bit_role_arn" {
  description = "FluentBit IAM role ARN"
  value       = aws_iam_role.fluent_bit.arn
}

output "fluent_bit_role_name" {
  description = "FluentBit IAM role name"  
  value       = aws_iam_role.fluent_bit.name
}

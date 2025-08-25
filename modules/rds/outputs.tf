output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_proxy_endpoint" {
  description = "RDS proxy endpoint"
  value       = aws_db_proxy.main.endpoint
}

output "db_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}

output "db_proxy_secret_arn" {
  description = "RDS proxy secret ARN"
  value       = aws_secretsmanager_secret.rds_proxy.arn
}

output "db_kms_key_arn" {
  description = "RDS KMS key ARN"
  value       = aws_kms_key.rds.arn
} 
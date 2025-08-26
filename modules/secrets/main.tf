resource "aws_kms_key" "secrets" {
  description             = "KMS key for Secrets Manager encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${var.project}-secrets-kms-key"
  }
}

resource "aws_kms_alias" "secrets" {
  name_prefix = "alias/${var.project}-secrets-key"
  target_key_id = aws_kms_key.secrets.key_id
}

resource "aws_secretsmanager_secret" "main" {
  name = var.secret_name
  kms_key_id = aws_kms_key.secrets.arn
  recovery_window_in_days = 0

  tags = {
    Name = var.secret_name
  }
}

resource "aws_secretsmanager_secret_version" "main" {
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = jsonencode(var.secrets)
} 
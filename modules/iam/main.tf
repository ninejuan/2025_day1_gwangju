# External Secrets용 IAM 역할
resource "aws_iam_role" "external_secrets" {
  name = "${var.project}-external-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${var.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:sub" = "system:serviceaccount:external-secrets:external-secrets-sa"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project}-external-secrets-role"
  }
}

# External Secrets용 IAM 정책 (관리형 정책)
resource "aws_iam_policy" "external_secrets" {
  name = "${var.project}-external-secrets-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          var.app_secrets_arn,
          var.app_secrets_arn
        ]
      }
    ]
  })
}

# External Secrets용 KMS 정책 (별도 관리형 정책)
resource "aws_iam_policy" "external_secrets_kms" {
  name = "${var.project}-external-secrets-kms-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = var.kms_key_arns
      }
    ]
  })
}

# External Secrets IAM 역할에 정책 연결
resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}

resource "aws_iam_role_policy_attachment" "external_secrets_kms" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets_kms.arn
}

# FluentBit용 IAM 역할
resource "aws_iam_role" "fluent_bit" {
  name = "${var.project}-fluent-bit-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${var.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:sub" = "system:serviceaccount:amazon-cloudwatch:fluent-bit-sa"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project}-fluent-bit-role"
  }
}

# FluentBit용 IAM 정책
resource "aws_iam_role_policy" "fluent_bit" {
  name = "${var.project}-fluent-bit-policy"
  role = aws_iam_role.fluent_bit.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:ap-northeast-2:${var.account_id}:log-group:/gj2025/*"
        ]
      }
    ]
  })
}

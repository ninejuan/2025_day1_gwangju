resource "aws_iam_role" "codebuild" {
  name = "${var.project}-${var.app_name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project}-${var.app_name}-codebuild-role"
  }
}

resource "aws_iam_role_policy" "codebuild" {
  name = "${var.project}-${var.app_name}-codebuild-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:PutImage"
        ]
        Resource = var.ecr_repository_arn
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.github_token_arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.project}-${var.app_name}-artifacts-bucket",
          "arn:aws:s3:::${var.project}-${var.app_name}-artifacts-bucket/*"
        ]
      }
    ]
  })
}

resource "aws_codebuild_project" "main" {
  name          = "${var.project}-app-${var.app_name}-build"
  description   = "Build project for ${var.app_name} application"
  build_timeout = "10"
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "S3"
    location = "arn:aws:s3:::${var.project}-${var.app_name}-artifacts-bucket"
    name = "${var.project}-${var.app_name}-build-artifacts"
    packaging = "NONE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "REPOSITORY_URI"
      value = var.ecr_repository_url
      type  = "SECRETS_MANAGER"
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
      type  = "SECRETS_MANAGER"
    }
  }

  source {
    type      = "GITHUB"
    location  = "https://github.com/cloud53/gj2025-repository.git"
    buildspec = "buildspec.yaml"
    
    auth {
      type = "SECRETS_MANAGER"
      resource = var.github_token_arn
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/${var.project}/build/${var.app_name}"
      stream_name = "build-logs"
    }
  }

  tags = {
    Name = "${var.project}-app-${var.app_name}-build"
  }
}

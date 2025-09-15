resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-db-subnet-group"
  subnet_ids = var.data_subnet_ids

  tags = {
    Name = "${var.project}-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.project}-db-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all TCP traffic"
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all UDP traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "${var.project}-db-sg"
  }
}

resource "aws_kms_key" "rds" {
  description = "KMS key for RDS encryption"
  enable_key_rotation = true

  tags = {
    Name = "${var.project}-db-kms-key"
  }
}

resource "aws_db_instance" "main" {
  identifier = "${var.project}-db-instance"
  
  engine         = "mysql"
  engine_version = "8.0.42"
  instance_class = var.instance_class
  
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true
  kms_key_id           = aws_kms_key.rds.arn
  
  db_name  = var.db_name
  username = var.master_username
  password = var.master_password
  port     = var.db_port
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  enabled_cloudwatch_logs_exports = ["audit", "error", "general"]
  
  skip_final_snapshot = true
  deletion_protection = true
  
  tags = {
    Name = "${var.project}-db-instance"
  }
}

resource "aws_db_proxy" "main" {
  name                   = "${var.project}-rds-proxy"
  debug_logging          = false
  engine_family          = "MYSQL"
  idle_client_timeout    = 1800
  require_tls            = false
  role_arn               = aws_iam_role.rds_proxy.arn
  vpc_security_group_ids = [aws_security_group.rds.id]
  vpc_subnet_ids         = var.private_subnet_ids

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.rds_proxy.arn
  }

  tags = {
    Name = "${var.project}-rds-proxy"
  }
}

resource "aws_db_proxy_default_target_group" "main" {
  db_proxy_name = aws_db_proxy.main.name

  connection_pool_config {
    connection_borrow_timeout    = 120
    init_query                   = "SELECT 1"
    max_connections_percent      = 100
    max_idle_connections_percent = 50
  }
}

resource "aws_db_proxy_target" "main" {
  db_instance_identifier = aws_db_instance.main.identifier
  db_proxy_name          = aws_db_proxy.main.name
  target_group_name      = aws_db_proxy_default_target_group.main.name
}

resource "aws_iam_role" "rds_proxy" {
  name = "${var.project}-rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project}-rds-proxy-role"
  }
}

resource "aws_iam_role_policy" "rds_proxy" {
  name = "${var.project}-rds-proxy-policy"
  role = aws_iam_role.rds_proxy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.rds_proxy.arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = aws_kms_key.rds.arn
      }
    ]
  })
}

resource "aws_secretsmanager_secret" "rds_proxy" {
  name       = "${var.project}-rds-proxy-secret"
  kms_key_id = aws_kms_key.rds.arn
  recovery_window_in_days = 0

  tags = {
    Name = "${var.project}-rds-proxy-secret"
  }
}

resource "aws_secretsmanager_secret_version" "rds_proxy" {
  secret_id     = aws_secretsmanager_secret.rds_proxy.id
  secret_string = jsonencode({
    username = var.master_username
    password = var.master_password
  })
}
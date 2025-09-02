resource "random_string" "s3_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "aws_s3_bucket" "helm_charts" {
  bucket = "${var.project}-helm-charts-bucket-${random_string.s3_suffix.result}"

  tags = {
    Name = "${var.project}-helm-charts-bucket-${random_string.s3_suffix.result}"
  }
}

resource "aws_s3_bucket_versioning" "helm_charts" {
  bucket = aws_s3_bucket.helm_charts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "helm_charts" {
  bucket = aws_s3_bucket.helm_charts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "helm_charts" {
  bucket = aws_s3_bucket.helm_charts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "helm_charts" {
  bucket = aws_s3_bucket.helm_charts.id

  rule {
    id     = "helm-charts-lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# Artifacts bucket for red application
resource "aws_s3_bucket" "red_artifacts" {
  bucket = "${var.project}-red-artifacts-bucket"

  tags = {
    Name = "${var.project}-red-artifacts-bucket"
  }
}

resource "aws_s3_bucket_versioning" "red_artifacts" {
  bucket = aws_s3_bucket.red_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "red_artifacts" {
  bucket = aws_s3_bucket.red_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "red_artifacts" {
  bucket = aws_s3_bucket.red_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Artifacts bucket for green application
resource "aws_s3_bucket" "green_artifacts" {
  bucket = "${var.project}-green-artifacts-bucket"

  tags = {
    Name = "${var.project}-green-artifacts-bucket"
  }
}

resource "aws_s3_bucket_versioning" "green_artifacts" {
  bucket = aws_s3_bucket.green_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "green_artifacts" {
  bucket = aws_s3_bucket.green_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "green_artifacts" {
  bucket = aws_s3_bucket.green_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
} 
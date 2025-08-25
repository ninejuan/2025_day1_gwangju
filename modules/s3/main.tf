resource "aws_s3_bucket" "helm_charts" {
  bucket = "${var.project}-helm-charts-bucket"

  tags = {
    Name = "${var.project}-helm-charts-bucket"
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
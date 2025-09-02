output "helm_charts_bucket_name" {
  description = "Helm charts S3 bucket name"
  value       = aws_s3_bucket.helm_charts.bucket
}

output "helm_charts_bucket_arn" {
  description = "Helm charts S3 bucket ARN"
  value       = aws_s3_bucket.helm_charts.arn
}

output "red_artifacts_bucket_name" {
  description = "Red application artifacts S3 bucket name"
  value       = aws_s3_bucket.red_artifacts.bucket
}

output "red_artifacts_bucket_arn" {
  description = "Red application artifacts S3 bucket ARN"
  value       = aws_s3_bucket.red_artifacts.arn
}

output "green_artifacts_bucket_name" {
  description = "Green application artifacts S3 bucket name"
  value       = aws_s3_bucket.green_artifacts.bucket
}

output "green_artifacts_bucket_arn" {
  description = "Green application artifacts S3 bucket ARN"
  value       = aws_s3_bucket.green_artifacts.arn
} 
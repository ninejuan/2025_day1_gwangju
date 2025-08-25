output "helm_charts_bucket_name" {
  description = "Helm charts S3 bucket name"
  value       = aws_s3_bucket.helm_charts.bucket
}

output "helm_charts_bucket_arn" {
  description = "Helm charts S3 bucket ARN"
  value       = aws_s3_bucket.helm_charts.arn
} 
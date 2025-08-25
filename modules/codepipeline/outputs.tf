output "pipeline_name" {
  description = "CodePipeline name"
  value       = aws_codepipeline.main.name
}

output "pipeline_arn" {
  description = "CodePipeline ARN"
  value       = aws_codepipeline.main.arn
}

output "artifact_bucket_name" {
  description = "Artifact bucket name"
  value       = aws_s3_bucket.artifacts.bucket
}

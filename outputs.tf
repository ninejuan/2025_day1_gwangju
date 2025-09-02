# VPC Outputs
output "hub_vpc_id" {
  description = "Hub VPC ID"
  value       = module.vpc.hub_vpc_id
}

output "app_vpc_id" {
  description = "Application VPC ID"
  value       = module.vpc.app_vpc_id
}

# Bastion Outputs
output "bastion_public_ip" {
  description = "Bastion host public IP"
  value       = module.bastion.bastion_public_ip
}

output "bastion_private_ip" {
  description = "Bastion host private IP"
  value       = module.bastion.bastion_private_ip
}

# EKS Outputs
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

# RDS Outputs
output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_endpoint
}

output "db_proxy_endpoint" {
  description = "RDS proxy endpoint"
  value       = module.rds.db_proxy_endpoint
}

# ECR Outputs
output "red_repository_url" {
  description = "Red ECR repository URL"
  value       = module.ecr.repository_urls["red"]
}

output "green_repository_url" {
  description = "Green ECR repository URL"
  value       = module.ecr.repository_urls["green"]
}

# Load Balancer Outputs
output "external_nlb_dns_name" {
  description = "External NLB DNS name"
  value       = module.load_balancers.external_nlb_dns_name
}

output "internal_alb_dns_name" {
  description = "Internal ALB DNS name"
  value       = module.load_balancers.internal_alb_dns_name
}

# Secrets Outputs
output "app_secrets_arn" {
  description = "Application secrets ARN"
  value       = module.app_secrets.secret_arn
}

output "github_token_arn" {
  description = "GitHub token ARN"
  value       = module.github_token.secret_arn
}

# S3 Outputs
output "helm_charts_bucket_name" {
  description = "Helm charts S3 bucket name"
  value       = module.s3.helm_charts_bucket_name
}

# Transit Gateway Outputs
output "transit_gateway_id" {
  description = "Transit Gateway ID"
  value       = module.transit_gateway.transit_gateway_id
}

# Network Firewall Outputs
output "network_firewall_id" {
  description = "Network Firewall ID"
  value       = module.network_firewall.firewall_id
}

# IAM Outputs
output "external_secrets_role_arn" {
  description = "External Secrets IAM role ARN"
  value       = module.iam.external_secrets_role_arn
}

output "external_secrets_role_name" {
  description = "External Secrets IAM role name"
  value       = module.iam.external_secrets_role_name
}
